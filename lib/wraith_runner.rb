class WraithRunner

  def initialize(config_name)
    @config = (config_name)
    @directory = "/public/#{config_name}"
  end

  def directory
    @directory
  end

  def run_wraith
    folders = Wraith::FolderManager.new(@config)
    folders.clear_shots_folder
    folders.create_folders
    spider = Wraith::Spidering.new(@config)
    spider.check_for_paths
    save_images = Wraith::SaveImages.new(@config)
    save_images.save_images
    @directory = save_images.directory
    crop = Wraith::CropImages.new(@config)
    crop.crop_images
    compare = Wraith::CompareImages.new(@config)
    compare.compare_images
    thumbs = Wraith::Thumbnails.new(@config)
    thumbs.generate_thumbnails
    gallery = Wraith::GalleryGenerator.new(@config)
    gallery.generate_gallery
  end

  def has_differences?

    diff = 0

    Dir.glob("#{@directory}/**/*.txt") { |fn|
      data = File.open(fn, 'rb') { |io| io.read }
      diff = diff+data.to_i
    }
    unless diff.is_a?(Numeric)
	return true
    end
    diff > 0

  end


end
