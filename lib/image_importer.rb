require 'net/http'
require 'zip/zip'
class ImageImporter

  def self.download_zip(zip_url)
    uri = URI(zip_url)
    
    ffname = "imgzip_#{Process.pid}#{rand(20)}"
    zip_file = "#{Rails.root}/tmp/#{ffname}.zip"
    
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      http.request request do |response|
        open zip_file, 'wb' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end

    return ffname, zip_file
  end

  def self.import(products, zip_url, replace, skip)
    
    ffname, zip_file = download_zip(zip_url)
    new_dir = "#{Rails.root}/tmp/#{ffname}"
    Dir.mkdir(new_dir)
    unzip_file(zip_file, new_dir)    
    
    Dir.chdir(new_dir)
    product_folders = Dir.glob('*').select {|f| File.directory? f}
    
    pf_count = 0
    puts "Number of folders found: #{product_folders.size}"
    product_folders.each do |pf|      
      product = products.find_by_name(pf)
      if product.blank?      
        puts "----------------------- No product with the name #{pf} found" 
        next 
      end
      if skip and !product.images.empty? #skip
        puts "----------------------- skipping product #{product.name} "
        next
      end
      if replace #clear out all images
        puts "----------------------- clearing images for #{product.name} "
        product.images = [] 
      end
      upload_pics_for(product, pf)
      pf_count +=1
      puts "ran upload_pics_for for #{pf_count} products"
    end

  end

  def self.import_by_sku(products, zip_url, replace=false, skip=false)
    #download and unzip to folder
    ffname, zip_file = download_zip(zip_url)
    new_dir = "#{Rails.root}/tmp/#{ffname}"
    Dir.mkdir(new_dir)
    unzip_file(zip_file, new_dir) 
    Dir.chdir(new_dir)
    #get images
    ids = products.not_deleted.select(:id).collect {|p| p.id }
    vs  = Spree::Variant.where(:product_id => ids)
    image_files = Dir.glob('*').select {|f| File.file? f}

    tmp = 0
    siz = vs.size
    for v in vs
      next if v.sku.blank? or (!v.product.images.blank? and skip)
      puts "\n\n Finding images for #{v.sku} - #{tmp} of #{siz} \n\n"
      
      image_files.each do |img_file|
        i = img_file.gsub(/\D/, "") #get numeric part
        zeros = 4-i.length
        zeros.times { i += "0" }

        puts "Uploading image file for #{v.sku} with file #{img_file} - (#{i})" if v.sku[0..3].eql?(i)
        upload_image(v.product, img_file) if v.sku[0..3].eql?(i)
      end
      tmp +=1
    end

  end

  def self.upload_image(product, image_file)
    file = File.open(image_file, 'rb')
    i = product.images.build(:attachment => file, :alt => product.name)
    geometry = Paperclip::Geometry.from_file(file)
    i.setup_square(geometry) unless geometry.width.eql?(0) or geometry.height.eql?(0)
    i.save
  end

  def self.upload_pics_for(product, product_folder)
    Dir.chdir(product_folder) do
      image_files = Dir.glob('*').select {|f| File.file? f}
      image_files.each do |img_file|
        upload_image(product, img_file)
      end
    end
  end

  def self.unzip_file (file, destination)
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
        f_path=File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
  end

end