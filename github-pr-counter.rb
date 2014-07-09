require 'httparty'

class GithubAccess
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

class StatusBoard
  include HTTParty
  base_uri 'http://sweet-econ-dashboard.herokuapp.com'

  TOKEN = 'YOUR_AUTH_TOKEN'

  def initialize
    @options = { "auth_token" => "#{TOKEN}" }
  end

  def send data
    items = parsed data
    options = @options.merge(items: items).to_json
    self.class.post("/widgets/pulls", body: options)
  end

  private

  def parsed data
    data.collect { |name, value| { "label" => name, "value" => value } }
  end
end

class PrCounter
  USERS = %w{@mattheworiordan @IanVaughan @billbillington @dpiatek @kouno @oturley @SimonWoolf}
  USERS_REGEXP = Regexp.new USERS.join('|')

  def initialize
    @github = GithubAccess.new
    @status_board = StatusBoard.new
  end

  def run
    update_board with crunched fetched_data
  end

  private

  def fetch_data
    @github.pull_requests
  end
  alias :fetched_data :fetch_data

  def crunch data
    open_prs = Hash.new(0)
    mentions = Hash.new(0)

    data.each do |pr|
      print '.'
      mention = Hash.new(0)

      user = pr['user']['login']
      pr_number = pr['number']

      open_prs["@#{user}"] += 1
      found_users = pr['body'].scan USERS_REGEXP
      found_users.each { |u| mention[u] = 1 }

      review_comments = @github.issues(pr_number)
      review_comments.each do |comment|
        found_users = comment['body'].scan USERS_REGEXP
        found_users.each { |u| mention[u] = 1 }
      end
      mentions.merge!(mention) { |k,a,b| a + b }
    end

    mentions.tap {|h| (USERS - mentions.keys).each {|u| h[u]=0 }}

    #@open_pr_count = Hash[open_prs.sort_by{|a,b|b}.reverse]
    #@mentions_count = Hash[mentions.sort_by{|a,b|b}.reverse]
    Hash[mentions.sort_by{|a,b|b}]
  end
  alias :crunched :crunch

  def update_board data
    #@mentions_count = {"@kouno"=>7, "@mattheworiordan"=>7, "@SimonWoolf"=>3, "@billbillington"=>3, "@dpiatek"=>3, "@IanVaughan"=>1}
    @status_board.send data
  end

  def with data
    data
  end
end

PrCounter.new.run
