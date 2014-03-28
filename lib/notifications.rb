require File.join(File.dirname(__FILE__), 'email.rb');
require File.join(File.dirname(__FILE__), 'slack.rb');
class Notifications

  def initialize(config, config_name, build_label, logger)
    @config = config
    @config_name = config_name
    @build_label = build_label
    @logger = logger
  end

  def send
    unless @config['wraith_daemon']['notifications']['enabled']
      @logger.info 'Notifications are switched off, will not send any'
      return
    end

    notifications = @config['wraith_daemon']['notifications']
    if notifications.include? 'email'
      mailer = Emailer.new(@config, @build_label)
        mailer.send message
      end

    if notifications.include? 'slack'
      mailer = Slack.new(@config, @build_label)
        mailer.send message
      end


  end


  def message
    report_location = @config['wraith_daemon']['report_location']
    message = <<MESSAGE
Wraith spotted some differences.
Check #{report_location}/builds/#{@config_name}/#{@build_label} for details
MESSAGE
    message
  end

end
