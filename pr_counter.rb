require 'httparty'
require_relative 'github'
require_relative 'status_board'

class PrCounter
  USERS = %w{@mattheworiordan @IanVaughan @billbillington @dpiatek @kouno @oturley @SimonWoolf}
  USERS_REGEXP = Regexp.new USERS.join('|')

  def initialize
    @github = Github.new
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

    mentions.tap { |h| (USERS - mentions.keys).each {|u| h[u]=0 } }

    #@open_pr_count = Hash[open_prs.sort_by{|a,b|b}.reverse]
    Hash[mentions.sort_by{|a,b|b}]
  end
  alias :crunched :crunch

  def update_board data
    @status_board.send data
  end

  def with data
    data
  end
end

PrCounter.new.run
