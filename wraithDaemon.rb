require 'sinatra'
require 'wraith'
require 'net/smtp'
require 'yaml'

@daemonConfig = YAML::load(File.open("configs/config.yaml"))

def doit(pidFile)


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
  email

end

def email


  message = <<MESSAGE
From: #{@daemonConfig['wrait_daemon']['notifications']['from']}
To: #{@daemonConfig['wrait_daemon']['notifications']['to']}
Subject: #{@daemonConfig['wrait_daemon']['notifications']['subject']}

wraith done with errors
MESSAGE

  Net::SMTP.start('mx.gc2.dc1.gnm') do |smtp|
    smtp.send_message message, @daemonConfig['wrait_daemon']['notifications']['from'], @daemonConfig['wrait_daemon']['notifications']['to']
  end


end

#set :root, File.dirname(__FILE__)
#set :static, true
#set :public_dir, Proc.new { File.join(File.dirname(__FILE__), "public") }

set :port, @daemonConfig['wrait_daemon']['port']

get '/' do

  params = request.env['rack.request.query_hash']

  pidFile = File.expand_path("wraith.pid", File.dirname(__FILE__));

  if File.exist? pidFile
    return "Work already in progress, check the gallery for results"
  end

  #if params.include? "fork"
  pid = fork do
    doit(pidFile)
  end
  File.open(pidFile, 'w') { |file| file.write("#{pid}") }
  "Started process pid: #{pid}<br/>The results will be visible at /gallery.html"
  #end
  #
  #doit(pidFile)
  #
  #redirect to '/gallery.html'

end
