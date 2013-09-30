Spree::Core::Engine.routes.prepend do
  namespace :admin do
    get 'import_images' => 'image_importer#index', :as => :image_importer
    post 'import_images' => 'image_importer#import', :as => :image_importer
  end
end