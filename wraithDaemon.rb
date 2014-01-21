require 'sinatra'
require 'wraith/manager'

#set :root, File.dirname(__FILE__)
#set :static, true
#set :public_dir, Proc.new { File.join(File.dirname(__FILE__), "public") }


get '/' do

  pid = fork do
    @wraith_manager = WraithManager.new('config');
    @wraith_manager.reset_shots_folder
    @wraith_manager.check_for_paths
    @wraith_manager.save_images
    @wraith_manager.crop_images
    @wraith_manager.compare_images
    @wraith_manager.generate_thumbnails
    @wraith_manager.generate_gallery
  end

  "Started process pid: #{pid}<br/>The results will be visible at /gallery.html"

end
