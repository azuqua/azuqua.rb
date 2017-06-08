# Azuqua Client Rubygem

This library provides an interface for interacting with your Azuqua flos.
The Azuqua API is directly exposed to developers should you wish to write your own library.
For full API documentation please visit <a href="https://api.azuqua.com">api.azuqua.com</a>.

Installation:
```
gem 'azuqua', :git => 'git@github.com:azuqua/azuqua.rb.git'
```

In order to make API requests you will need your accessKey and accessSecret.
These can be found on your account information page. 

# Usage

```ruby
# Load accessKey & accessSecret via environment variables
# Checks for variables `AZUQUA_ACCESS_KEY` and `AZUQUA_ACCESS_SECRET` respectivly
azuqua = Azuqua.from_env()

# Alternativly to load from a JSON file with { accessKey: "", accessSecret: "" }
# azuqua = Azuqua.from_config([PATH])

# OR - call initialize new azuqua passing in key and secret to constructor
# azuqua = Azuqua.new([KEY], [SECRET])

# Invokes an Azuqua Flo - returns Flo output as a Hash
# Params:
# - flo_alias: string alias of flo that will be invoked
# - data: Hash containing data to be send in request
# - verb: string representation of HTTP method (GET, POST, etc) defaults to "POST"
puts azuqua.invoke("ALIAS", { name: "Ruby" })

# Invoke with GET request (data populates `query`) section of API entpoint Flo
puts azuqua.invoke("ALIAS", { name: "Ruby" }, "GET")

# Invoke showing complex Hash in body
puts azuqua.invoke("ALIAS", {
  :user => {
    :name => "Rails"
  },
  :org => {
    :name => "Ruby"
  }
})

# List all flos a user has access to - returns an array of Hashes each representing a Flo
# Params:
# - data: Hash of optional query parameters
# - data.org_id: Filter to flos only in org_id
# - data.type: Filter to flos only with type
puts azuqua.list_flos({ org_id: my_org })

# Example of listing and invoking every Flo the user has access to
flos = azuqua.list_flos({})
flos.each do |flo|
  azuqua.invoke(flo["alias"], { example: "data" })
end

# Enables (turns on) a Flo - return response as a Hash
# Params:
# - flo_alias: string alias of flo that will be enabled
azuqua.enable_flo("ALIAS")

# Disables (turns off) a Flo - returns response as a Hash
# Params:
# - flo_alias: string alias of flo that will be disabled
azuqua.disable_flo("ALIAS")

# Retrieve the inputs for a Flo - returns Flo inputs as a Hash
# Params:
# - flo_alias: string alias of flo whos inputs will be returned
puts azuqua.flo_inputs("ALIAS")

# Retrieve the outputs of the first method of a Flo - return Flo outputs as a Hash
# Params:
# - flo_alias: string alias of flo whos outputs will be returned
puts azuqua.flo_outputs("ALIAS")

# Reads an Azuqua Flo - return Flo metdata as a Hash
# Params:
# - flo_alias: string alias of flo that will be read
puts azuqua.flo_read("ALIAS")

# List all orgs a user has access to - returns an array of Hashes each representing an Org
puts azuqua.list_orgs()

# Resumes a paused flo by execution_id - returns Flo response as a Hash
# Params:
# - flo_alias: string alias of flo that will be disabled
# - execution_id: string execution_id of paused flo
# - data: hash of data to be sent to resume card
# - verb: string representation of HTTP method (GET, POST, etc) defaults to "POST"
puts azuqua.request("/flo/ALIAS/invoke", "GET", { language: 'ruby' })
```

# LICENSE - "MIT License"
Copyright (c) 2017 Azuqua

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
