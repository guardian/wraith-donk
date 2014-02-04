wraithDaemon
============

Created to wrap wraith in a web server, so you could kick off work with a CI hook, and see the results whilst using one port only.

You can set it up to host multiple projects.
Simply copy the ```configs/config.yaml``` to ```configs/<project_name>.yaml``` to set project specific settings.
Within these files, make sure to set the ```directory``` directive to ```public/<project_name>```


Usage
=====

```ruby wraithDaemon.rb````

This will start up a Sinatra server on port 4567

Go to ```localhost:4567/<project_name>``` to kick it off


Go to ```localhost:4567/<project_name>/gallery.html``` to view the results.




...

and put a donk on it.
