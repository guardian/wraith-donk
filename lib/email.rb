require 'net/smtp'
class Emailer

  def initialize(config, build_label)
    @config_name = config
    @build_label = build_label
  end

  def send(message)
    t = @config['wraith_daemon']['notifications']['types'];
    x = t.find { |h| h['email'] }
    if x==nil
      return
    end

    smtp_host = x['email']['smtp_host']
    from = x['email']['from']
    to = x['email']['to']
    subject = x['email']['subject']
    message = <<MESSAGE
From: #{from}
To: #{to}
Subject: #{subject}

    #{message}

---
put a donk on it
MESSAGE

    Net::SMTP.start(smtp_host) do |smtp|
      smtp.send_message message, from, to
    end

  end

end
