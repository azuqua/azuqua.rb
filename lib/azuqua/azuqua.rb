require "rubygems"
require "json"
require "openssl"
require "time"
require "net/https"
require "uri"

class Azuqua
  VERSION = "1.0.0"

	HTTP_OPTIONS = {
		:host => "https://api.azuqua.com", 
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

  def self.from_config(path)
    open(path, "r") do |file|
      data = JSON.parse(file.read)
      accessKey = data["accessKey"]
      accessSecret = data["accessSecret"]
      Azuqua.new(accessKey, accessSecret)
    end
  end

  def self.from_env()
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

  # Invokes an Azuqua Flo
  def invoke(floAlias, data, verb="POST")
    invokeRoute = "/flo/" + floAlias + "/invoke";
    request(invokeRoute, verb, data)
  end

  # Alias for invoke
  def invoke_flo(floAlias, data, verb="POST")
    invoke(floAlias, verb, data)
  end

  def flo_read(floAlias)
    route = "/flo/" + floAlias + "/read"
    request(route, "GET", {})
  end

  # Retrieve the inputs for a Flo
  def flo_inputs(floAlias)
    route = "/flo/" + floAlias + "/inputs"
    request(route, "GET", {})
  end

  # Retrieve the outputs of the first method of a Flo
  def flo_outputs(floAlias)
    route = "/flo/" + floAlias + "/outputs"
    request(route, "GET", {})
  end

  # Enables (turns on) a Flo
  def enable_flo(floAlias)
    route = "/flo/" + floAlias + "/enable"
    request(route, "POST", {})
  end

  # Disables (turns off) a Flo
  def disable_flo(floAlias)
    route = "/flo/" + floAlias + "/disable"
    request(route, "POST", {})
  end

  # Resumes a paused Flo by execution ID
  def resume_flo(floAlias, execution_id, data, verb="POST")
    route = "/flo/" + floAlias + "/resume/" + execution_id
    request(route, verb, data)
  end

  # Retrieves a generated swagger definition for an open HTTP endpoint Flo
  def flo_swagger(floAlias)
    route = "/flo/" + floAlias + "/swaggerDefinition"
    request(route, "GET", {})
  end

  # List all flos a user has access to
  # Supported keys to filter by inside of data are 'org_id' and 'type'
  def list_flos(data)
    route = "/org/flos"
    request(route, "GET", data)
  end

  # Make an arbitrary request to an Azuqua API endpoint
  # Path being just the path E.G: '/azuqua/ALIAS/invoke
  # Verb being the HTTP verb
  # Data being data passed to the route (GET data in querystring) (Post in body)
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

  # Static helper function for generating 'x-api-hash'
  def self.sign_data(secret, path, verb, data, timestamp)
    if (verb == "get" || verb == "delete") && data.empty?
        data = ""
    elsif
      data = data.to_json
    end
    meta = [verb.downcase, path, timestamp].join(":") + data
    OpenSSL::HMAC.hexdigest("sha256", secret, meta)
  end


end
