require "rubygems"
require "json"
require "time"

class Org
	ROUTES = {
		:list => {
			:path => "/org/flos",
			:method => "get"
		},
	}

	@name = nil
	@key = nil
	@secret = nil
	@@floCache = nil

	attr_reader :name, :key, :secret

	def initialize _name, _key, _secret
		@name = _name
		@key = _key
		@secret = _secret
	end

	# returns all flos for an org
	def flos _refresh
		if _refresh || @@floCache.nil?
			resp = ::Azuqua.request(ROUTES[:list][:path], ROUTES[:list][:method], nil, @key, @secret)
			@@floCache = resp.map { |f| 
				::Flo.new(f["name"], f["alias"], self) 
			}
		else
			@@floCache
		end
	end

	# Static method that reads the org name, key, and secret from a config json file. Returns a new Org object.
	def self.loadConfig path
		open(path, "r") do |file|
			data = JSON.parse(file.read)
			@key = data["accessKey"]
			@secret = data["accessSecret"]
			@name = data["name"]
			self.new(@name, @key, @secret)
			raise "Invalid account credentials" unless @@accessKey && @@accessSecret
		end
	end
end