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

  def review_comments(pr)
    self.class.get("/repos/" + death_star_path + "issues/#{pr}/comments", @options).parsed_response
  end

  private

  def death_star_path
    'econsultancy/death_star/'
  end
end

class PrCounter
  USERS = %w{mattheworiordan IanVaughan billbillington dpiatek kouno oturley SimonWoolf}
  USERS_REGEXP = Regexp.new USERS.map {|u| "@#{u}" }.join('|')

  def initialize
    @github = GithubAccess.new
  end

  def run
    fetch_data
    crunch
  end

  private

  def fetch_data
    @pr_data = @github.pull_requests
  end

  def crunch
    open_prs = Hash.new(0)
    mentions = Hash.new(0)

    @pr_data.each do |pr|
      print '.'
      mention = Hash.new(0)

      user = pr['user']['login']
      pr_number = pr['number']

      open_prs["@#{user}"] += 1
      found_users = pr['body'].scan USERS_REGEXP
      found_users.each { |u| mention[u] = 1 }

      comments = @github.comments(pr_number)
      comments.each do |comment|
        found_users = comment['body'].scan USERS_REGEXP
        found_users.each { |u| mention[u] = 1 }
      end

      review_comments = @github.review_comments(pr_number)
      review_comments.each do |comment|
        found_users = comment['body'].scan USERS_REGEXP
        found_users.each { |u| mention[u] = 1 }
      end
      mentions.merge!(mention) { |k,a,b| a + b }
    end

    puts
    puts Hash[open_prs.sort_by{|a,b|b}.reverse]
    puts Hash[mentions.sort_by{|a,b|b}.reverse]
  end
end

PrCounter.new.run
