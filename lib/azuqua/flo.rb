
require "rubygems"
require "json"
require "time"
require "openssl"
require "net/https"
require "uri"

class Flo

	ROUTES = {
		:invoke => {
			:path => "/flo/:id/invoke",
			:method => "post"
		},
		:list => {
			:path => "/account/flos",
			:method => "get"
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

	def initialize _name, _alias
		@name = _name
		@alias = _alias
	end

	# static method to list all flos for your account
	def self.all _refresh=false
		if _refresh || @@floCache.nil?
			@@floCache = self.request(ROUTES[:list][:path], ROUTES[:list][:method], nil)
				.map { |f| self.new(f["name"], f["alias"]) }
		else
			@@floCache
		end
	end

	# instance method to invoke a flo
	def invoke _data
		if @name && @alias
			self.class.request(ROUTES[:invoke][:path].gsub(":id", @alias), ROUTES[:invoke][:method], _data)
		else
			raise "Invalid flo name or alias"
		end
	end

	private

	def add_get_parameter _path, _key, _value
		delimiter = _path.include?("?") ? "&" : "?"
		_path + delimiter + URI.encode_www_form_component(_key) + "=" + URI.encode_www_form_component(_value)
	end

	def self.request _path, _verb, _data
		_data = "" if _data.nil? || _data.empty?
		headers = HTTP_OPTIONS[:headers].dup
		timestamp = Time.now.utc.iso8601
		headers["x-api-timestamp"] = timestamp
		headers["x-api-accessKey"] = self.account[:accessKey]
		headers["x-api-hash"] = self.sign_data(self.account[:accessSecret], _data, _verb, _path, timestamp)
		if _verb == "get" && _data.is_a?(Hash)
			_path += URI.encode_www_form(_data)
		elsif _verb == "post"
			body = _data.to_json
			headers["Content-Length"] = body.bytesize.to_s
		end
		uri = URI.parse(HTTP_OPTIONS[:host] + _path)
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = true
		if _verb == "get"
			req = Net::HTTP::Get.new(uri.path, headers)
		else
			req = Net::HTTP::Post.new(uri.path, headers)
			req.body = body
		end
		res = https.request(req)
		begin
			res.body = JSON.parse(res.body)
		rescue
			raise "Error processing request " + res.body.to_s
		else
			code = res.code.to_i
			case code
				when 200 then res.body
				when 400..599 then raise res.body["error"]
			end
		end
	end

	def self.account
		::Azuqua.account
	end

	def self.sign_data _secret, _data, _verb, _path, _timestamp
		_data = _data.to_json if _data.is_a?(Hash)
		meta = [_verb.downcase, _path, _timestamp].join(":")
		OpenSSL::HMAC.hexdigest("sha256", _secret, meta + _data)
	end

end
