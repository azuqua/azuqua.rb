require "rubygems"
require File.expand_path("../../lib/azuqua/azuqua", __FILE__)

RSpec.describe Azuqua, "#invoke" do
  context "basic usage of invoke and arbitrary API" do
    it "invokes some flos without raising an exception" do
      # Load accessKey & accessSecret via environment variables
      # Checks for variables `AZUQUA_ACCESS_KEY` and `AZUQUA_ACCESS_SECRET` respectivly
      azuqua = Azuqua.from_env()

      #Alternativly to load from a JSON file with { accessKey: '', accessSecret: '' }
      # azuqua = Azuqua.from_config([PATH])

      # OR - call initialize new azuqua passing in key and secret to constructor
      # azuqua = Azuqua.new([KEY], [SECRET])
      #

      #Invoke 
      puts azuqua.invoke('ALIAS', { name: 'Ruby' })

      #Invoke with GET request (data populates `query`) section of API entpoint Flo
      puts azuqua.invoke('ALIAS', { name: 'Ruby' }, 'GET')

      #Invoke showing complex Hash in body
      puts azuqua.invoke('ALIAS', {
        :user => {
          :name => 'Rails'
        },
        :org => {
          :name => 'Ruby'
        }
      })

      #Make an arbitrary request to an Azuqua API endpoint
      puts azuqua.request('ALIAS', 'GET', { orgId: 18 })

      expect(true).to eq true
    end
  end
end
