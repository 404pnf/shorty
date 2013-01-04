require "sinatra"
require "redis"
require "hiredis"
require "uri"

uri = URI.parse(ENV['REDISTOGO_URL'])
$redis = Redis.new(:driver => :hiredis, :host => uri.host, :port => uri.port, :password => uri.password)

class Url
  def initialize(url) @url = url end
  def to_short() @url.hash.to_s(36) end
end

put "/new" do
  uri = URI::parse(params[:url])
  raise "Invalid URL" unless uri.kind_of? URI::HTTP or uri.kind_of? URI::HTTPS

  url = Url.new uri.to_s
  hash = url.to_short

  unless $redis.exists(hash)
    $redis.set hash, uri.to_s
    $redis.hset :clickdata, hash, 0
  end

  [200, hash]
end

delete "/:urlhash" do
  unless $redis.get params[:urlhash].nil?
    $redis.del params[:urlhash]
    201
  end
  404
end

get "/:urlhash" do
  unless $redis.get params[:urlhash].nil?
    $redis.hincrby :clickdata, params[:urlhash], 1
    redirect to($redis.get params[:urlhash]), 301
  end
  404
end

get "/stats/:urlhash" do
  unless $redis.get params[:urlhash].nil?
    data = $redis.hget :clickdata, params[:urlhash]
    url = $redis.get params[:urlhash]
    return [200, "Url: #{url} Clicks: #{data}"]
  end
  404
end
