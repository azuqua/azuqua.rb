
require "rubygems"
require "json"
require "openssl"
require "net/https"
require "uri"

class Flo

	ROUTES = {
		:invoke => {
			:path => "/api/flo/:id/invoke",
			:method => "POST"
		},
		:list => {
			:path => "/api/account/flos",
			:method => "POST"
		}
	}

	HTTP_OPTIONS = {
		:host => "https://api.azuqua.com",
		:headers => {
			"Content-Type" => "application/json"
		}
	}

	@@floCache = nil

	attr_reader :name, :alias

	def initialize name, _alias
		@name = name
		@alias = _alias
	end

	# static method to list all flos for your account
	def self.list refresh=false
		if refresh || @@floCache.nil?
			@@floCache = self.request(ROUTES[:list][:path], {}).map { |f| self.new(f["name"], f["alias"]) }
		else
			@@floCache
		end
	end

	# instance method to invoke a flo
	def invoke data
		if @name && @alias
			self.class.request(ROUTES[:invoke][:path].gsub(":id", @alias), data)["data"]
		else
			raise "Invalid flo name or alias"
		end
	end

	private

	def self.request path, data
		body = {
			:accessKey => self.account[:accessKey],
			:data => data,
			:hash => self.sign_data(self.account[:accessSecret], data)
		}
		uri = URI.parse(HTTP_OPTIONS[:host] + path)
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = true
		req = Net::HTTP::Post.new(uri.path, HTTP_OPTIONS[:headers])
		req.body = body.to_json
		res = https.request(req)
		code = res.code.to_i
		case code
			when 200 then JSON.parse(res.body)
			when 400..599 then raise JSON.parse(res.body)["error"]
		end
	end

	def self.account
		::Azuqua.account
	end

	def self.sign_data secret, data
		OpenSSL::HMAC.hexdigest("sha256", secret, data.to_json)
	end

end
