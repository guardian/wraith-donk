require 'sinatra'
require 'wraith'
require 'net/smtp'
require 'yaml'
require File.join(File.dirname(__FILE__), '/lib/email.rb')
require File.join(File.dirname(__FILE__), '/lib/wraith_wrapper.rb')

@daemonConfig = YAML::load(File.open("configs/daemon.yaml"))
set :port, @daemonConfig['port']

get '/:config' do

  config = params[:config]

  unless File.exist? "configs/#{config}.yaml"
    return "Configuration does not exist";
  end

  pid_file = File.expand_path("wraith_#{config}.pid", File.dirname(__FILE__));

  if File.exist? pid_file
    return "Work already in progress, check the gallery for results"
  end

  pid = fork do
    File.open(pid_file, 'w') { |file| file.write("") }

    wrapper = WraithWrapper.new config
    wrapper.run_wraith

    File.delete pid_file

    emailer = Emailer.new config
    emailer.send
  end

  File.open(pid_file, 'w') { |file| file.write("#{pid}") }
  "Started process pid: #{pid}<br/>The results will be visible at /#{config}/gallery.html"

end
