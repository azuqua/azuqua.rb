# Azuqua Client Rubygem

This library provides an interface for interacting with your Azuqua flos.
The Azuqua API is directly exposed to developers should you wish to write your own library.
For full API documentation please visit <a href="https://api.azuqua.com">api.azuqua.com</a>.

Installation:
```
gem 'azuqua', :git => 'https://github.com/azuqua/azuqua.rb.git'
```

In order to make API requests you will need your accessKey and accessSecret.
These can be found on your account information page. 

# Usage

```ruby
# Load accessKey & accessSecret via environment variables
# Checks for variables `AZUQUA_ACCESS_KEY` and `AZUQUA_ACCESS_SECRET` respectivly
azuqua = Azuqua.from_env()

# Alternativly to load from a JSON file with { accessKey: '', accessSecret: '' }
# azuqua = Azuqua.from_config([PATH])

# OR - call initialize new azuqua passing in key and secret to constructor
# azuqua = Azuqua.new([KEY], [SECRET])
#

# Invoke 
puts azuqua.invoke('ALIAS', { name: 'Ruby' })

# Invoke with GET request (data populates `query`) section of API entpoint Flo
puts azuqua.invoke('ALIAS', { name: 'Ruby' }, 'GET')

# Invoke showing complex Hash in body
puts azuqua.invoke('ALIAS', {
  :user => {
    :name => 'Rails'
  },
  :org => {
    :name => 'Ruby'
  }
})

# Example of listing metadata about flos in your org
puts azuqua.list_flos({ org_id: my_org })

# Example of listing and invoking every Flo the user has access to
flos = azuqua.list_flos({})
flos.each do |flo|
  azuqua.invoke(flo['alias'], { example: "data" })
end

# Enable a Flo
azuqua.enable_flo('ALIAS')

# Disable a Flo
azuqua.disable_flo('ALIAS')

# Read Inputs of a Flo
puts azuqua.flo_inputs('ALIAS')

# Read Outputs of a Flo
puts azuqua.flo_outputs('ALIAS')

# Make an arbitrary request to an Azuqua API endpoint
puts azuqua.request('ALIAS', 'GET', { orgId: 18 })
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
