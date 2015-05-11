
require "rubygems"
require "json"
require "time"
require "openssl"
require "net/https"
require "net/http"
require "uri"
require File.expand_path("../azuqua/org", __FILE__)

module Azuqua
	ROUTES = {
		:login => {
			:path => "/org/login",
			:method => "post"
		}
	}

	HTTP_OPTIONS = {
		:host => "https://api.azuqua.com", 
		:headers => {
			"Content-Type" => "application/json"
		}
	}

	@@accessKey = nil
	@@accessSecret = nil

	def self.config key, secret
		@@accessKey = key
		@@accessSecret = secret
		raise "Invalid account credentials" unless @@accessKey && @@accessSecret
	end
	
	def self.account
		unless @@accessKey.nil? || @@accessSecret.nil?
			{
				:accessKey => @@accessKey,
				:accessSecret => @@accessSecret
			}
		else
			raise "Invalid account credentials"
		end
	end

	# Make requests with the provided key and secret
	def self.request _path, _verb, _data, _key, _secret
		_data = "" if _data.nil? || _data.empty?
		headers = HTTP_OPTIONS[:headers].dup
		timestamp = Time.now.utc.iso8601
		headers["x-api-timestamp"] = timestamp
		headers["x-api-accessKey"] = _key
		headers["x-api-hash"] = self.sign_data(_secret, _data, _verb, _path, timestamp)
		if _verb == "get" && _data.is_a?(Hash)
			_path += URI.encode_www_form(_data)
		elsif _verb == "post"
			body = _data.to_json
			headers["Content-Length"] = body.bytesize.to_s
		end
		uri = URI.parse(HTTP_OPTIONS[:host] + _path)
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = true
		http = Net::HTTP.new(uri.host, uri.port)
		if _verb == "get"
			req = Net::HTTP::Get.new(uri.path, headers)
		else
			req = Net::HTTP::Post.new(uri.path, headers)
			req.body = body
		end

		if (uri.scheme == "https")
			res = https.request(req)
		else
			res = http.request(req)
		end
		
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

	def self.sign_data _secret, _data, _verb, _path, _timestamp
		_data = _data.to_json if _data.is_a?(Hash)
		meta = [_verb.downcase, _path, _timestamp].join(":")
		OpenSSL::HMAC.hexdigest("sha256", _secret, meta + _data)
	end

	# Login with an email and password. Returns a list of Org objects
	def self.login _email, _password
		loginInfo = {
			:email => _email,
			:password => _password 
		}
		resp = self.request(ROUTES[:login][:path], ROUTES[:login][:method], loginInfo, "", "").map { |e|
			Org.new(e["name"], e["access_key"], e["access_secret"])
		}	
	end 

end
