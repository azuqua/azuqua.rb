
require "rubygems"
require "json"
require File.expand_path("../azuqua/flo", __FILE__)

module Azuqua
	Flo = ::Flo

	@@accessKey = nil
	@@accessSecret = nil

	def self.config key, secret
		@@accessKey = key
		@@accessSecret = secret
		raise "Invalid account credentials" unless @@accessKey && @@accessSecret
	end

	def self.loadConfig path
		open(path, "r") do |file|
			data = JSON.parse(file.read)
			@@accessKey = data["accessKey"]
			@@accessSecret = data["accessSecret"]
			raise "Invalid account credentials" unless @@accessKey && @@accessSecret
		end
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

end
