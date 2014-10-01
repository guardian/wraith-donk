require 'sinatra'
require 'wraith'
require 'yaml'
require 'json'
require 'log4r'
require 'haml'
require 'log4r/yamlconfigurator'
require File.join(File.dirname(__FILE__), '/lib/notifications.rb')
require File.join(File.dirname(__FILE__), '/lib/wraith_runner.rb')
require File.join(File.dirname(__FILE__), '/lib/build_history.rb')
require File.join(File.dirname(__FILE__), '/lib/build_queue.rb')
require File.join(File.dirname(__FILE__), '/lib/daemon_config.rb')
require File.join(File.dirname(__FILE__), '/lib/project_manager.rb')

LOGGER_CONFIG_FILE_PATH = 'configs/wraith_logger.yaml'

if File.exists? 'configs/daemon.yaml'
  daemon_config = YAML::load(File.open('configs/daemon.yaml'))
  set :port, daemon_config['port']
  set :bind, daemon_config['listen']
end

get '/' do
  project_manager = ProjectManager.new
  @projects = project_manager.projects
  haml :home
end

get '/health-check' do
  build_queue = BuildQueue.new
  if ( build_queue.length < 3)
    "OK"
  else
    status 400
    body 'Not OK'
  end
end

get '/:config/latest' do
  daemon_config = DaemonConfig.new
  config = params[:config]
  conf_dir=daemon_config.config_dir
  config_file = "#{conf_dir}/#{config}.yaml"


  unless File.exist? config_file
    return 'Configuration does not exist'
  end

  builds = BuildHistory.new config
  latest = builds.history.last
  redirect "/history/#{config}/#{latest}/gallery.html"
end

get '/builds/:config/:label' do
  daemon_config = DaemonConfig.new
  config = params[:config]
  label = params[:label]
  conf_dir=daemon_config.config_dir
  config_file = "#{conf_dir}/#{config}.yaml"


  unless File.exist? config_file
    return 'Configuration does not exist'
  end

  file = "public/history/#{config}/#{label}/gallery.html"
  unless File.exists? file
    return 'Build does not exist'
  end
  @src = "/history/#{config}/#{label}/gallery.html"
  haml :build

end


get '/:config' do

  config = params[:config]
  build_label = 0;
  if params.include? 'label'
    build_label = params['label']
  end

  start(config, build_label)

end

get '/cleanup/:config' do

  config = params[:config]
  builds = BuildHistory.new config

  builds.cleanup
  "cleaned #{config}"

end


def start(config, build_label)

  Log4r::Logger.new('donk')
  daemon_config = DaemonConfig.new

  if File.exist? LOGGER_CONFIG_FILE_PATH
    Log4r::YamlConfigurator.load_yaml_file(LOGGER_CONFIG_FILE_PATH)
  end
  logger = Log4r::Logger.get('donk')

  builds = BuildHistory.new config
  build_queue = BuildQueue.new

  conf_dir=daemon_config.config_dir
  config_file = "#{conf_dir}/#{config}.yaml"


  unless File.exist? config_file
    return 'Configuration does not exist'
  end

  run_config = YAML::load(File.open(config_file))

  pid_file = File.expand_path('wraith.pid', File.dirname(__FILE__))

  if File.exist? pid_file
    build_queue.add(config, build_label)
    return "Work already in progress. Your build was added to the queue of #{build_queue.length} jobs"
  end

  pid = fork do
    File.open(pid_file, 'w') { |file| file.write("") }

    runner = WraithRunner.new(config_file, config, build_label, logger)
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
