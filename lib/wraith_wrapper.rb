class WraithWrapper

  def initialize(configName)
    @config = (configName)
  end

  def run_wraith
    folders = Wraith::FolderManager.new(@config)
    folders.clear_shots_folder
    folders.create_folders
    spider = Wraith::Spidering.new(@config)
    spider.check_for_paths
    save_images = Wraith::SaveImages.new(@config)
    save_images.save_images
    crop = Wraith::CropImages.new(@config)
    crop.crop_images
    compare = Wraith::CompareImages.new(@config)
    compare.compare_images
    thumbs = Wraith::Thumbnails.new(@config)
    thumbs.generate_thumbnails
    gallery = Wraith::GalleryGenerator.new(save_images.directory)
    gallery.generate_gallery
  end


end
