class StatusBoard
  include HTTParty
  base_uri 'http://sweet-econ-dashboard.herokuapp.com'

  TOKEN = 'YOUR_AUTH_TOKEN'

  def initialize
    @options = { "auth_token" => "#{TOKEN}" }
  end

  def send data
    items = parse data
    options = @options.merge(items: items).to_json
    self.class.post("/widgets/pulls", body: options)
  end

  def parse data
    data.collect { |name, value| { "label" => name, "value" => value } }
  end
end
