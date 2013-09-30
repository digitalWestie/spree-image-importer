require 'image_importer.rb'

class Admin::ImageImporterController < Spree::Admin::BaseController

  def index
    #TODO: products selector
  end
  
  def import
    products = Spree::Product.all
    location = params[:import_url]
    skip = params[:add_replace_skip].eql?("skip")
    replace = params[:add_replace_skip].eql?("replace")
    
    if (location =~ URI::regexp).nil?
      @errors = "Not a valid url: #{location}"
      render :index
    else
      ImageImporter.delay.import(products, location, replace, skip)
      redirect_to main_app.admin_image_importer_path(), :notice => "Added import to worker queue."
    end
  end

end