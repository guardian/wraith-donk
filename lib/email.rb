class Emailer

  def initialize(configName)
    @config = YAML::load(File.open("configs/#{configName}.yaml"))
  end

  def send

    smtp_host = @config['wraith_daemon']['notifications']['smtp_host']
    from = @config['wraith_daemon']['notifications']['from']
    to = @config['wraith_daemon']['notifications']['to']
    subject = @config['wraith_daemon']['notifications']['subject']
    message = <<MESSAGE
From: #{from}
To: #{to}
Subject: #{subject}

wraith done with errors

---
put a donk on it
MESSAGE

    Net::SMTP.start(smtp_host) do |smtp|
      smtp.send_message message, from, to
    end

  end

end
