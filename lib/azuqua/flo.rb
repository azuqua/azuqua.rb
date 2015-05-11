
require "rubygems"
require "json"
require "time"
require "openssl"
require "net/https"
require "net/http"
require "uri"

class Flo

	ROUTES = {
		:invoke => {
			:path => "/flo/:id/invoke",
			:method => "post"
		},
		:read => {
			:path => "/flo/:id/read",
			:method => "get"
		},
		:enable => {
			:path => "/flo/:id/enable",
			:method => "get"
		},
		:disable => {
			:path => "/flo/:id/disable",
			:method => "get"
		}
	}

	@@floCache = nil
	@org = nil

	attr_reader :name, :alias

	def initialize _name, _alias, _org
		@name = _name
		@alias = _alias
		@org = _org 
	end

	# instance method to invoke a flo
	def invoke _data
		if @name && @alias
			request(ROUTES[:invoke][:path].gsub(":id", @alias), ROUTES[:invoke][:method], _data)
		else
			raise "Invalid flo name or alias"
		end
	end

	# instance method to read a flo
	def read 
		if @name && @alias
			request(ROUTES[:read][:path].gsub(":id", @alias), ROUTES[:read][:method], nil)
		else
			raise "Invalid flo name or alias"
		end
	end

	# instance method to enable a flo
	def enable 
		if @name && @alias
			request(ROUTES[:enable][:path].gsub(":id", @alias), ROUTES[:enable][:method], nil)
		else
			raise "Invalid flo name or alias"
		end
	end

	# instance method to disable a flo
	def disable 
		if @name && @alias
			request(ROUTES[:disable][:path].gsub(":id", @alias), ROUTES[:disable][:method], nil)
		else
			raise "Invalid flo name or alias"
		end
	end

	private

	def request _path, _method, _data
		if @name && @alias && @org.key && @org.secret
			::Azuqua.request(_path, _method, _data, @org.key, @org.secret)
		else 
			raise 'Invalid key, secret, flo name, or flo alias'
		end
	end 

	def add_get_parameter _path, _key, _value
		delimiter = _path.include?("?") ? "&" : "?"
		_path + delimiter + URI.encode_www_form_component(_key) + "=" + URI.encode_www_form_component(_value)
	end
end
