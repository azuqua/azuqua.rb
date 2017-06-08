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
      raise "Invalid account credentials. Missing accessKey or accessSecret"
    end
  end

  # Invokes an Azuqua Flo - returns Flo output as a Hash
  # Params:
  # - flo_alias: string alias of flo that will be invoked
  # - data: Hash containing data to be send in request
  # - verb: string representation of HTTP method (GET, POST, etc) defaults to "POST"
  def invoke(flo_alias, data, verb="POST")
    invokeRoute = "/flo/" + flo_alias + "/invoke";
    request(invokeRoute, verb, data)
  end

  # Alias for invoke
  def invoke_flo(flo_alias, data, verb="POST")
    invoke(flo_alias, verb, data)
  end

  # Reads an Azuqua Flo - return Flo metdata as a Hash
  # Params:
  # - flo_alias: string alias of flo that will be read
  def flo_read(flo_alias)
    route = "/flo/" + flo_alias + "/read"
    request(route, "GET", {})
  end

  # Retrieve the inputs for a Flo - returns Flo inputs as a Hash
  # Params:
  # - flo_alias: string alias of flo whos inputs will be returned
  def flo_inputs(flo_alias)
    route = "/flo/" + flo_alias + "/inputs"
    request(route, "GET", {})
  end

  # Retrieve the outputs of the first method of a Flo - return Flo outputs as a Hash
  # Params:
  # - flo_alias: string alias of flo whos outputs will be returned
  def flo_outputs(flo_alias)
    route = "/flo/" + flo_alias + "/outputs"
    request(route, "GET", {})
  end

  # Enables (turns on) a Flo - return response as a Hash
  # Params:
  # - flo_alias: string alias of flo that will be enabled
  def enable_flo(flo_alias)
    route = "/flo/" + flo_alias + "/enable"
    request(route, "POST", {})
  end

  # Disables (turns off) a Flo - returns response as a Hash
  # Params:
  # - flo_alias: string alias of flo that will be disabled
  def disable_flo(flo_alias)
    route = "/flo/" + flo_alias + "/disable"
    request(route, "POST", {})
  end

  # Resumes a paused flo by execution_id - returns Flo response as a Hash
  # Params:
  # - flo_alias: string alias of flo that will be disabled
  # - execution_id: string execution_id of paused flo
  # - data: hash of data to be sent to resume card
  # - verb: string representation of HTTP method (GET, POST, etc) defaults to "POST"
  def resume_flo(flo_alias, execution_id, data, verb="POST")
    route = "/flo/" + flo_alias + "/resume/" + execution_id
    request(route, verb, data)
  end

  # Retrieves a generated swagger definition for an open HTTP endpoint Flo - returns Swagger Def as a Hash
  # Params:
  # - flo_alias: string alias of flo whos swagger will be returned
  def flo_swagger(flo_alias)
    route = "/flo/" + flo_alias + "/swaggerDefinition"
    request(route, "GET", {})
  end

  # List all flos a user has access to - returns an array of Hashes each representing a Flo
  # Params:
  # - data: Hash of optional query parameters
  # - data.org_id: Filter to flos only in org_id
  # - data.type: Filter to flos only with type
  def list_flos(data)
    route = "/user/flos"
    request(route, "GET", data)
  end

  # List all orgs a user has access to - returns an array of Hashes each representing an Org
  def list_orgs()
    route = "/user/orgs"
    request(route, "GET", {})
  end

  # Make an arbitrary request to an Azuqua API endpoint
  # Params:
  #   - path: string of API path E.G: /flo/ALIAS/invoke
  #   - verb: string representation of HTTP method to use
  #   - data: Hash of data to be sent with request
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
