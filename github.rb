require 'httparty'

class Github
  include HTTParty
  base_uri 'https://api.github.com'

  TOKEN = '29ff0d408c258fc28f246e3335612d019417f9f6'

  def initialize
    @options = {
      headers: {
        "Authorization" => "token #{TOKEN}",
        "User-Agent" => 'HTTParty'
      }
    }
  end

  def pull_requests
    self.class.get("/repos/" + death_star_path + "pulls", @options)
  end

  def comments(pr)
    self.class.get("/repos/" + death_star_path + "pulls/#{pr}/comments", @options).parsed_response
  end

  def issues(pr)
    self.class.get("/repos/" + death_star_path + "issues/#{pr}/comments", @options).parsed_response
  end

  private

  def death_star_path
    'econsultancy/death_star/'
  end
end
