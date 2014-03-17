require 'sinatra'
require 'wraith'
require 'yaml'
require 'json'
require 'log4r'
require 'log4r/yamlconfigurator'
require File.join(File.dirname(__FILE__), '/lib/notifications.rb')
require File.join(File.dirname(__FILE__), '/lib/wraith_runner.rb')
require File.join(File.dirname(__FILE__), '/lib/build_history.rb')
require File.join(File.dirname(__FILE__), '/lib/build_queue.rb')

LOGGER_CONFIG_FILE_PATH = 'configs/wraith_logger.yaml'

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

  Log4r::Logger.new('donk')
  daemon_config = YAML::load(File.open('configs/daemon.yaml'))

  if File.exist? LOGGER_CONFIG_FILE_PATH
    Log4r::YamlConfigurator.load_yaml_file(LOGGER_CONFIG_FILE_PATH)
  end
  logger = Log4r::Logger.get('donk')

  builds = BuildHistory.new config
  build_queue = BuildQueue.new

  if daemon_config['config_location'] == nil
    conf_dir='configs'
  else
    conf_dir=daemon_config['config_location']
  end

  unless File.exist? "#{conf_dir}/#{config}.yaml"
    return 'Configuration does not exist'
  end

  run_config = YAML::load(File.open("#{conf_dir}/#{config}.yaml"))
  report_location = run_config['wraith_daemon']['report_location']

  pid_file = File.expand_path('wraith.pid', File.dirname(__FILE__));

  if File.exist? pid_file
    build_queue.add(config, build_label)
    return "Work already in progress. Your build was added to the queue of #{build_queue.length} jobs"
  end

  pid = fork do
    File.open(pid_file, 'w') { |file| file.write("") }

    runner = WraithRunner.new("#{conf_dir}/#{config}.yaml", config, build_label, logger)
    runner.run_wraith
    builds.add(build_label)

    File.delete pid_file

    if runner.has_differences?
      logger.info 'Some difference spotted, will send notifications'
      notifier = Notifications.new(run_config, config, build_label, logger)
      notifier.send
    else
      logger.info 'No difference spotted, will not send notifications'
    end

    builds.cleanup

    unless build_queue.empty?
      logger.debug 'There are tasks in the build queue, taking the oldest one'
      conf, label = build_queue.next
      logger.debug "Running #{config} with the label: #{label}"
      start(conf, label)
      build_queue.save
    end

  end

  File.open(pid_file, 'w') { |file| file.write("#{pid}") }
  "Started process pid: #{pid}"

end
