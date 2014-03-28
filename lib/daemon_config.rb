class DaemonConfig
  def initialize
    @daemon_config = YAML::load(File.open('configs/daemon.yaml'))
  end

  def config_dir
    if @daemon_config['config_location'] == nil
      'configs'
    else
      @daemon_config['config_location']
    end
  end

end
