class Emailer

  def initialize(config_name)
    @config = YAML::load(File.open("configs/#{config_name}.yaml"))
    @config_name = config_name
  end

  def send

    unless @config['wraith_daemon']['notifications']['enabled']
      puts 'Notifications are switched off, will not send emails'
      return
    end

    smtp_host = @config['wraith_daemon']['notifications']['smtp_host']
    from = @config['wraith_daemon']['notifications']['from']
    to = @config['wraith_daemon']['notifications']['to']
    subject = @config['wraith_daemon']['notifications']['subject']
    report_location = @config['wraith_daemon']['report_location']
    message = <<MESSAGE
From: #{from}
To: #{to}
Subject: #{subject}

Wraith done with errors.
Check #{report_location}/#{@config_name}/gallery.html for details

---
put a donk on it
MESSAGE

    Net::SMTP.start(smtp_host) do |smtp|
      smtp.send_message message, from, to
    end

  end

end
