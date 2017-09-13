require "rubygems"
require "json"
require "openssl"
require "time"
require "net/https"
require "uri"

class Azuqua
  VERSION = "2.0.0"

  HTTP_OPTIONS = {
    :host => "https://api.azuqua.com:443", 
    :headers => {
      "Content-Type" => "application/json"
    }
  }

  ROUTES = JSON.parse(File.read(File.join(File.dirname(__FILE__), "/static/routes.json")))

  @accessKey = nil
  @accessSecret = nil

  def initialize(key, secret)
    @accessKey = key
    @accessSecret = secret
    ROUTES.each do |routeGroupKey, routeGroup|
      routeGroup.each do |routeName, route|
        method = route["methods"][0].upcase
        path = route["path"]
        params = path.split("/").select { |part| part.start_with?(':') }
        self.define_singleton_method(routeName) do |*args|
          newPath = path;
          params.each_with_index { |param, idx|
            newPath.sub!(param, "#{args[idx]}")
          }
          data = {};
          if method == 'POST' || method == 'PUT' && args.length > params.length
            if args[args.length - 1].is_a?(Hash)
              data = args[args.length - 1];
            end
          end
          request(newPath, method, data);
        end
      end
    end
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

  # headers, query, body, files, method
  def invoke(flo_alias, data)
    method, headers, query, body, files = data.values_at(:method, :headers, :query, :body, :files)
    method = method.upcase
    endpoint = "/v2/flo/#{flo_alias}/invoke"
    if !query.empty?
      endpoint = endpoint + "?" + URI.encode_www_form(query)
    end
    if method == "GET" || method == "DELETE"
      body = nil
    end
    request(endpoint, method, body, headers)
  end

  # Make an arbitrary request to an Azuqua API endpoint
  # Params:
  #   - path: string of API path E.G: /flo/ALIAS/invoke
  #   - verb: string representation of HTTP method to use
  #   - data: Hash of data to be sent with request
  def request(path, verb, data, additional_headers)
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
      # data = Hash[URI.decode_www_form(querystring)]
      path = path + "?" + querystring
      # Set data to empty - it's now in the query string
      data = {}
    end

    timestamp = Time.now.utc.iso8601
    headers = HTTP_OPTIONS[:headers].dup
    headers["x-api-timestamp"] = timestamp
    headers["x-api-accessKey"] = @accessKey
    headers["x-api-hash"] = Azuqua.sign_data(@accessSecret, path, verb, data, timestamp)
    headers["Content-Type"] = "application/json"

    additional_headers.each do |key, value|
      headers[key] = value
    end

    uri = URI.parse(HTTP_OPTIONS[:host] + path)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    if verb == "get"
      req = Net::HTTP::Get.new(uri, headers)
    elsif verb == "delete"
      req = Net::HTTP::Delete.new(uri, headers)
    elsif verb == "put"
      req = Net::HTTP::Put.new(uri, headers)
      req.body = data.to_json
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
    if data.empty?
      data = ""
    else
      data = data.to_json
    end
    meta = [verb.downcase, path, timestamp].join(":") + data
    OpenSSL::HMAC.hexdigest("sha256", secret, meta)
  end


end
