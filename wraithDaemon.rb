require 'sinatra'
require 'wraith'

#set :root, File.dirname(__FILE__)
#set :static, true
#set :public_dir, Proc.new { File.join(File.dirname(__FILE__), "public") }


get '/' do

  pidFile = File.expand_path("wraith.pid", File.dirname(__FILE__));

  if File.exist? pidFile
    return "Work already in progress, check the gallery for results"
  end

  pid = fork do
    File.open(pidFile, 'w') { |file| file.write("") }
    @config = ('config')
    folders = Wraith::FolderManager.new(@config)
    folders.clear_shots_folder
    folders.create_folders
    spider = Wraith::Spidering.new(@config)
    spider.check_for_paths
    @save_images = Wraith::SaveImages.new(@config)
    @save_images.save_images
    crop = Wraith::CropImages.new(@config)
    crop.crop_images
    compare = Wraith::CompareImages.new(@config)
    compare.compare_images
    thumbs = Wraith::Thumbnails.new(@config)
    thumbs.generate_thumbnails
    gallery = Wraith::GalleryGenerator.new(@save_images.directory)
    gallery.generate_gallery
    File.delete pidFile
  end
  File.open(pidFile, 'w') { |file| file.write("#{pid}") }
  "Started process pid: #{pid}<br/>The results will be visible at /gallery.html"

end
