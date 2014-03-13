require File.join(File.dirname(__FILE__), 'email.rb');
require File.join(File.dirname(__FILE__), 'slack.rb');
class Notifications

  def initialize(config_name, build_label)
    @config = YAML::load(File.open("configs/#{config_name}.yaml"))
    @config_name = config_name
    @build_label = build_label
  end

  def send
    unless @config['wraith_daemon']['notifications']['enabled']
      puts 'Notifications are switched off, will not send any'
      #return
    end

    notifications = @config['wraith_daemon']['notifications']['types']
    notifications.each { |type|
      x = type.keys.first
      if x=='email'
        mailer = Emailer.new(@config, @build_label)
        mailer.send message
      end

      if x=='slack'
        mailer = Slack.new(@config, @build_label)
        mailer.send message
      end


    }

  end


  def message
    report_location = @config['wraith_daemon']['report_location']
    message = <<MESSAGE
Wraith spotted some differences.
Check #{report_location}/history/#{@config_name}/#{@build_label}/gallery.html for details
MESSAGE
    message
  end

end
