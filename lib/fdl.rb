require "sinatra"
require "sinatra/base"
require "haml"
require "date"

module Fdl
  class WebApp < Sinatra::Base
    set :root, File.expand_path("../..", __FILE__)

    WHITELIST = %w(127.0.0.1)

    get "/" do
      halt 403 unless WHITELIST.include? request.ip
      redirect "/show"
    end

    get "/log" do
      if params[:message].nil? || /\A\s*\Z/ =~ params[:message]
        halt 400
      end

      WebApp.push(params[:message])
      204
    end

    get "/show" do
      halt 403 unless WHITELIST.include? request.ip

      @date = Date.today
      if File.exists?(WebApp.log_file_path)
        @logs = File.readlines(WebApp.log_file_path).reverse
      else
        @logs = ["Nothing logged yet"]
      end

      haml :show
    end

    get "/clear" do
      halt 403 unless WHITELIST.include? request.ip

      if File.exists?(WebApp.log_file_path)
        File.delete(WebApp.log_file_path)
      end

      redirect "/show"
    end

    private

    def self.push message
      File.open(log_file_path, "a+") do |f|
        f.puts "<small>#{Time.now.strftime("%m/%d/%Y at %H:%M")} </small> #{message}"
      end
    end

    def self.log_file_path
      File.expand_path(File.dirname(__FILE__)).gsub(/\/lib\z/, "/public/log.txt")
    end
  end
end
