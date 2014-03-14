require 'sinatra'
require 'wraith'
require 'yaml'
require 'json'
require File.join(File.dirname(__FILE__), '/lib/notifications.rb')
require File.join(File.dirname(__FILE__), '/lib/wraith_runner.rb')
require File.join(File.dirname(__FILE__), '/lib/build_history.rb')
require File.join(File.dirname(__FILE__), '/lib/build_queue.rb')

if File.exists? 'configs/daemon.yaml'
  daemon_config = YAML::load(File.open('configs/daemon.yaml'))
  set :port, daemon_config['port']
  set :bind, daemon_config['listen']
end

get '/:config' do

  config = params[:config]
  build_label = 0;
  if params.include? 'label'
    build_label = params['label']
  end

  start(config, build_label)

end

def start(config, build_label)
  builds = BuildHistory.new config
  build_queue = BuildQueue.new

  unless File.exist? "configs/#{config}.yaml"
    return 'Configuration does not exist'
  end

  run_config = YAML::load(File.open("configs/#{config}.yaml"))
  report_location = run_config['wraith_daemon']['report_location']

  pid_file = File.expand_path('wraith.pid', File.dirname(__FILE__));

  if File.exist? pid_file
    build_queue.add(config, build_label)
    return "Work already in progress. Your build was added to the queue of #{build_queue.length} jobs"
  end

  pid = fork do
    File.open(pid_file, 'w') { |file| file.write("") }

    runner = WraithRunner.new(config, build_label)
    runner.run_wraith
    builds.add(build_label)

    File.delete pid_file

    if runner.has_differences?
      puts 'Some difference spotted, will send notifications'
      notifier = Notifications.new(config, build_label)
      notifier.send
    else
      puts 'No difference spotted, will not send notifications'
    end

    builds.cleanup

    unless build_queue.empty?
      conf, label = build_queue.next
      start(conf, label)
      build_queue.save
    end

  end

  File.open(pid_file, 'w') { |file| file.write("#{pid}") }
  "Started process pid: #{pid}"

end
