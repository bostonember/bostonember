require 'bundler/setup'
require 'rack-rewrite'
require 'multi_json'
require 'curb'

RACK_ENV          = ENV['RACK_ENV']

MEETUP_API_KEY    = ENV['MEETUP_API_KEY']
MEETUP_GROUP_ID   = "3934632"
MEETUP_API_URL    = "http://api.meetup.com/2"
MEETUP_QUERY      = "key=#{MEETUP_API_KEY}&group_id=#{MEETUP_GROUP_ID}"

class NoCache
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env).tap do |status, headers, body|
      headers["Cache-Control"] = "no-store"
    end
  end
end

use NoCache

# TODO: Forgive the hacks below.  Will clean up as time allows, as I'm
# trying to ship this demo for tomorrows meeting.
#
class MeetupAPI
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /api\/(.*)/
      handle_api_request(request)
    else
      @app.call(env)
    end
  end

  def handle_api_request(request)
    if request.path =~ /api\/(.*)/
      result = case $1
      when 'meetings'
        result = meetings
      when 'members'
        result = members
      else
        result = ""
      end
    end

    [200, { 'Content-Type' => 'application/json' }, [result]]
  end

  def meetup_api_request(resource)
    Curl::Easy.perform("#{MEETUP_API_URL}/#{resource}.json?#{MEETUP_QUERY}")
  end

  def meetings
    response_body        = meetup_api_request("events").body_str
    parsed_response_body = MultiJson.decode(response_body)

    results = parsed_response_body["results"].map do |result|
      {
        :id        => result["id"],
        :name      => result["name"],
        :event_url => result["event_url"]
      }
    end

    MultiJson.encode({ :meetings => results })
  rescue Exception => e
    ""
  end

  def members
    response_body        = meetup_api_request("members").body_str
    parsed_response_body = MultiJson.decode(response_body)

    results = parsed_response_body["results"].map do |result|
      {
        :id         => result["id"],
        :name       => result["name"],
        :link       => result["link"],
        :photo_link => result["photo"]["photo_link"],
        :thumb_link => result["photo"]["thumb_link"]
      }
    end

    MultiJson.encode({ :members => results })
  rescue Exception => e
    ""
  end
end

use MeetupAPI

use Rack::Rewrite do
  rewrite %r{^(.*)\/$}, '$1/index.html'
end

unless RACK_ENV == 'production'
  require 'rake-pipeline'
  require 'rake-pipeline/middleware'

  use Rake::Pipeline::Middleware, "Assetfile"
end

run Rack::Directory.new('public')
