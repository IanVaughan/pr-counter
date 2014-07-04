#dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
#require File.join(dir, 'httparty')
#require 'logger'
#require 'pp'
require 'httparty'

class GithubPrCounter
  include HTTParty
  base_uri 'https://api.github.com'
  #logger  ::Logger.new "httparty.log", :debug, :curl

  TOKEN = '29ff0d408c258fc28f246e3335612d019417f9f6'
  #default_params "Authorization" => TOKEN

  def initialize
    @options = {
      headers: {
        "Authorization" => "token #{TOKEN}",
        "User-Agent" => 'HTTParty'
      }
    }
  end

  def pr
    #self.class.get("/repos/" + death_star_path + "/pulls", @options)
    #self.class.get("/repos/" + death_star_path + "/pulls", logger: @my_logger, log_level: :debug, log_format: :curl)
    #self.class.get("/repos/" + death_star_path + "pulls/1698", @options)
    self.class.get("/repos/" + death_star_path + "pulls", @options)
  end

  def github_api_path
    'https://api.github.com/repos/'
  end

  def death_star_path
    'econsultancy/death_star/'
  end
end

prs = GithubPrCounter.new.pr
stat = Hash.new(0)
prs.each do |pr|
  stat[pr['user']['login']] += 1
end
puts stat
