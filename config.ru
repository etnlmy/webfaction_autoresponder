require 'rubygems'
require 'bundler'

Bundler.require

require './app.rb'
require './webfaction/endpoint.rb'

run Sinatra::Application