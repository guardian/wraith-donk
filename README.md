# Deprecated.

June 2018: This tool and repo is no longer maintained or used within the Guardian. 

wraith-donk
============

Created to wrap [Wraith](https://github.com/BBC-News/wraith) in a web server, so you could kick off work with a CI hook, and see the results whilst using one port only.

You can set it up to host multiple projects.
Simply copy the ```configs/config.yaml``` to ```configs/<project_name>.yaml``` to set project specific settings.
Within these files, make sure to set the ```directory``` directive to ```public/<project_name>```


Installation
============
```bundle install```

Usage
=====

```bundle exec ruby wraithDaemon.rb```

This will start up a Sinatra server on port 4567
You can configure the port by creating ```configs/daemon.yaml``` with the content:

```yaml
port: 80
```

Go to ```localhost:4567/<project_name>?label=<build_label>``` to kick it off

If configured in the ```configs/<project_name>.yaml```, it will send out an email notification if there's any difference spotted.

```yaml
#WraithDaemon
wraith_daemon:
  report_location: "http://localhost:4567"
  notifications:
    enabled: true
    email: #optional
      smtp_host: ""
      from: ""
      to: ""
      subject: ""
    slack: #optional
      url: http://project.slack.com/post-webhook...
```

Go to ```localhost:4567/history/<project_name>/<build_label>/gallery.html``` to view the results.

Alternatively you can set up your own web server, and point ```report_location``` to that url, and the notification e-mail will use that location instead.

...

[*Wraith: put a donk on it*](http://www.youtube.com/watch?v=ckMvj1piK58)
