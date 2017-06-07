require "rubygems"
require "json"
require "openssl"
require "time"
require "net/https"
require "uri"

class Azuqua
	HTTP_OPTIONS = {
		:host => "https://alphaapi.azuqua.com", 
		:headers => {
			"Content-Type" => "application/json"
		}
	}

  @accessKey = nil
  @accessSecret = nil

  def initialize(key, secret)
    @accessKey = key
    @accessSecret = secret
    raise "Invalid account credentials" unless @accessKey && @accessSecret
  end

  def self.fromConfig(path)
    open(path, "r") do |file|
      data = JSON.parse(file.read)
      accessKey = data["accessKey"]
      accessSecret = data["accessSecret"]
      Azuqua.new(accessKey, accessSecret)
    end
  end

  def self.fromEnv()
      accessKey = ENV["AZUQUA_ACCESS_KEY"]
      accessSecret = ENV["AZUQUA_ACCESS_SECRET"]
      Azuqua.new(accessKey, accessSecret)
  end

  def account
    unless @accessKey.nil? || @accessSecret.nil?
      {
        :accessKey => @accessKey,
        :accessSecret => @accessSecret
      }
    else
      raise "Invalid account credentials"
    end
  end

  def invoke(floAlias, data, verb="POST")
    invokeRoute = "/flo/" + floAlias + "/invoke";
    request(invokeRoute, verb, data)
  end

  def request(path, verb, data)
    verb = verb.downcase
    # Check data
    if data.nil?
      data = {}
    end
    if !data.is_a?(Hash)
      raise "Data must be nil or a Hash"
    end
    if (verb == "get" || verb == "delete") && !data.empty?
      querystring = URI.encode_www_form(data)
      # Server will decode QS for data (ints => string) this mimics that for hash
      data = Hash[URI.decode_www_form(querystring)]
      path = path + "?" + querystring
    end

    timestamp = Time.now.utc.iso8601
    headers = HTTP_OPTIONS[:headers].dup
    headers["x-api-timestamp"] = timestamp
    headers["x-api-accessKey"] = @accessKey
    headers["x-api-hash"] = Azuqua.sign_data(@accessSecret, path, verb, data, timestamp)
    headers["Content-Type"] = "application/json"
    puts headers

    uri = URI.parse(HTTP_OPTIONS[:host] + path)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    if verb == "get"
      req = Net::HTTP::Get.new(uri, headers)
    else
      req = Net::HTTP::Post.new(uri, headers)
      req.body = data.to_json
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

  def self.sign_data(secret, path, verb, data, timestamp)
    if (verb == "get" || verb == "delete") && data.empty?
        data = ""
    elsif
      data = data.to_json
    end
    meta = [verb.downcase, path, timestamp].join(":") + data
    puts meta
    OpenSSL::HMAC.hexdigest("sha256", secret, meta)
  end


end
