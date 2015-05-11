<h1>Azuqua Client Rubygem</h1>
<p>
	This library provides an interface for interacting with your Azuqua flos.
	The Azuqua API is directly exposed to developers should you wish to write your own library.
	For full API documentation please visit <a href="//developer.azuqua.com">developer.azuqua.com</a>.
</p>
<p>
	Installation:
	<pre> gem install azuqua </pre>
</p>
<p>
	In order to make API requests you will need your accessKey and accessSecret to your org.
	These can be found on your account information page. 

	You can also access your flos via your username and password. This method gives you access to all of your associated orgs in addition to each org's flos.
</p>
<h1>Usage</h1>
<pre>
	require './lib/azuqua.rb'
	require './lib/azuqua/flo.rb'
	require './lib/azuqua/org.rb'

	# Grab key, secret, email, and password from the environment variables.
	key = ENV["ACCESS_KEY"]
	secret = ENV["ACCESS_SECRET"]

	email = ENV["AZUQUA_EMAIL"]
	password = ENV["AZUQUA_PASSWORD"]

	# Login with your username and password. Returns a list of Org objects.
	orgs = Azuqua.login email, password
	orgs.each do  |org|
		org.flos(true).each do |flo| 
			p flo.read
			p flo.disable
			p flo.enable
			p flo.alias
			p flo.invoke '{"a":"test data"}'
		end
	end

	# Create a new org object with the org name, key and secret.
	org = Org.new 'Org Name', key, secret
	org.flos(true).each do |flo| 
		p flo.read
		p flo.disable
		p flo.enable
		p flo.alias
		p flo.invoke '{"a":"test data"}'
	end

	# Use loadConfig static method to load name, key and secret. The loadConfig method returns a new Org object.
	org = Org.loadConfig("path/to/file.json")
</pre>
<hr>
<h1>LICENSE - "MIT License"</h1>
Copyright (c) 2014 Azuqua

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
