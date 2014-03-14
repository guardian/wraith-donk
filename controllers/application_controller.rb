require 'sinatra'
require 'wraith'
require 'net/smtp'
require 'yaml'
require 'donk/email'
require 'donk/wraith_runner'

class ApplicationController < Sinatra::Base

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../', __FILE__)

  if File.exists? 'configs/daemon.yaml'
    daemon_config = YAML::load(File.open('configs/daemon.yaml'))
    set :port, daemon_config['port']
    set :bind, daemon_config['listen']
  end

  get '/:config' do

    config = params[:config]

    @message = ''

    unless File.exist? "configs/#{config}.yaml"
      return 'Configuration does not exist'
    end

    run_config = YAML::load(File.open("configs/#{config}.yaml"))
    report_location = run_config['wraith_daemon']['report_location']

    @pid_file = File.expand_path("wraith_#{config}.pid", File.dirname(__FILE__));

    if File.exist? @pid_file
      @message = 'Work already in progress, check the gallery for results'
    end

    pid = fork do
      File.open(pid_file, 'w') { |file| file.write("") }

      runner = WraithRunner.new config
      runner.run_wraith

      File.delete pid_file

      if runner.has_differences?
        @message = 'Some difference spotted, will send notifications'
        emailer = Emailer.new config
        emailer.send
      else
        @message = 'No difference spotted, will not send notifications'
      end
    end

    File.open(pid_file, 'w') { |file| file.write("#{pid}") }
    @mesage = "Started process pid: #{pid}<br/>The results will be visible at #{report_location}/#{config}/gallery.html"

    erb :runner
  end
end
