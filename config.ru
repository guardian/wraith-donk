require 'sinatra/base'

Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }

map('/') { run HomeController }
map('/test') { run ApplicationController }
