require 'net/http'
require 'uri'
require 'rest-client'
require 'aws-sdk'

class Emailer


  def initialize(config, build_label)
    @config = config
    @build_label = build_label
    @url = "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
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

    role = Net::HTTP.get(URI.parse(@url))
    role_url = "#{@url}#{role}"
                                  
    aws_details = JSON.parse(RestClient.get(role_url))

    ses = AWS::SimpleEmailService.new(
        :region => 'eu-west-1',
        :access_key_id => aws_details['AccessKeyId'],
        :secret_access_key => aws_details['SecretAccessKey'],
        :session_token => aws_details['Token']
    )

    ses.send_email(
        :to             => to,
        :from           => from,
        :subject        => subject,
        :body_text      => message
    )
  end

end
