require 'net/smtp'
class Emailer

  def initialize(config, build_label)
    @config = config
    @build_label = build_label
  end

  def send(message)
    conf = @config['wraith_daemon']['notifications']['email'];

    smtp_host = conf['smtp_host']
    from = conf['from']
    to = conf['to']
    subject = conf['subject']
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
