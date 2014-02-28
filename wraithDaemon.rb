require 'sinatra'
require 'wraith'
require 'net/smtp'
require 'yaml'
require File.join(File.dirname(__FILE__), '/lib/email.rb')
require File.join(File.dirname(__FILE__), '/lib/wraith_runner.rb')

if File.exists? 'configs/daemon.yaml'
  daemon_config = YAML::load(File.open('configs/daemon.yaml'))
  set :port, daemon_config['port']
  set :bind, daemon_config['listen']
end

get '/' do
    '<title>wraith-donk</title><iframe width="420" height="315" src="//www.youtube.com/embed/ckMvj1piK58" frameborder="0" allowfullscreen></iframe><br /><pre>To kick off a comparison go to /&lt;project_name&gt;<p>(Another fine tool from <a href="https://github.com/guardian">The Grauniad</a></pre>'
end

get '/:config' do

  config = params[:config]

  unless File.exist? "configs/#{config}.yaml"
    return 'Configuration does not exist'
  end

  run_config = YAML::load(File.open("configs/#{config}.yaml"))
  report_location = run_config['wraith_daemon']['report_location']

  pid_file = File.expand_path("wraith_#{config}.pid", File.dirname(__FILE__));

  if File.exist? pid_file
    return 'Work already in progress, check the gallery for results'
  end

  pid = fork do
    File.open(pid_file, 'w') { |file| file.write("") }

    runner = WraithRunner.new config
    runner.run_wraith

    File.delete pid_file

    if runner.has_differences?
      puts 'Some difference spotted, will send notifications'
      emailer = Emailer.new config
      emailer.send
    else
      puts 'No difference spotted, will not send notifications'
    end
  end

  File.open(pid_file, 'w') { |file| file.write("#{pid}") }
  "Started process pid: #{pid}<br/>The results will be visible at #{report_location}/#{config}/gallery.html"

end
