require "test/unit"
require "./lib/azuqua.rb"
require "./lib/azuqua/flo.rb"
require "./lib/azuqua/org.rb"

# TODO not working
class TestFlo < Test::Unit::TestCase
	@key = nil
	@secret = nil
	@email = nil
	@password = nil

	def setup
		@key = ENV["ACCESS_KEY"]		
		@secret = ENV["ACCESS_SECRET"]
		@email = ENV["AZUQUA_EMAIL"]
		@password = ENV["AZUQUA_PASSWORD"]		
	end 

	def test_simple
		orgs = Azuqua.login email, password
		orgs.each do  |org|
			org.flos(true).each do |flo| 
				assert_not_nil(flo.read, 'Should return the details about a flo.')
				assert_not_nil(flo.disable, 'Should return the details about a flo')
				assert_not_nil(flo.enable, 'Should return the details about a flo')
				assert_not_nil(flo.alias, 'Should return the details about a flo')
				assert_not_nil(flo.invoke '{"a":"test data"}', 'Should return the details about a flo')
			end
		end

		org = Org.new 'Org Name', key, secret
		org.flos(true).each do |flo| 
			assert_not_nil(flo.read, 'Should return the details about a flo.')
			assert_not_nil(flo.disable, 'Should return the details about a flo')
			assert_not_nil(flo.enable, 'Should return the details about a flo')
			assert_not_nil(flo.alias, 'Should return the details about a flo')
			assert_not_nil(flo.invoke '{"a":"test data"}', 'Should return the details about a flo')
		end
	end
end