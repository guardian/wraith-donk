require 'sinatra'
require 'wraith'

#set :root, File.dirname(__FILE__)
#set :static, true
#set :public_dir, Proc.new { File.join(File.dirname(__FILE__), "public") }


get '/' do

  pid = fork do
    @config = ('config')
    folders = Wraith::FolderManager.new(@config)
    folders.clear_shots_folder
    folders.create_folders
    spider = Wraith::Spidering.new(@config)
    spider.check_for_paths
    @save_images = Wraith::SaveImages.new(@config)
    @save_images.save_images
    crop = Wraith::CropImages.new(@save_images.directory)
    crop.crop_images
    compare = Wraith::CompareImages.new(@config)
    compare.compare_images
    thumbs = Wraith::Thumbnails.new(@config)
    thumbs.generate_thumbnails
    gallery = Wraith::GalleryGenerator.new(@save_images.directory)
    gallery.generate_gallery
  end

  "Started process pid: #{pid}<br/>The results will be visible at /gallery.html"

end
