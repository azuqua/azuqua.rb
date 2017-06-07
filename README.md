#Azuqua Client Rubygem

This library provides an interface for interacting with your Azuqua flos.
The Azuqua API is directly exposed to developers should you wish to write your own library.
For full API documentation please visit <a href="https://api.azuqua.com">api.azuqua.com</a>.

Installation:
```
gem 'azuqua', :git => 'https://github.com/azuqua/azuqua.rb.git'
```

In order to make API requests you will need your accessKey and accessSecret.
These can be found on your account information page. 

#Usage

```ruby
# Load accessKey & accessSecret via environment variables
# Checks for variables `AZUQUA_ACCESS_KEY` and `AZUQUA_ACCESS_SECRET` respectivly
azuqua = Azuqua.fromEnv()

#Alternativly to load from a JSON file with { accessKey: '', accessSecret: '' }
# azuqua = Azuqua.fromConfig([PATH])

# OR - call initialize new azuqua passing in key and secret to constructor
# azuqua = Azuqua.new([KEY], [SECRET])
#

#Invoke 
puts azuqua.invoke('a22cbad4f0f9902fd7dc2e5875a8ee14', { name: 'Ruby' })

#Invoke with GET request (data populates `query`) section of API entpoint Flo
puts azuqua.invoke('a22cbad4f0f9902fd7dc2e5875a8ee14', { name: 'Ruby' }, 'GET')

#Invoke showing complex Hash in body
puts azuqua.invoke('a22cbad4f0f9902fd7dc2e5875a8ee14', {
  :user => {
    :name => 'Rails'
  },
  :org => {
    :name => 'Ruby'
  }
})

#Make an arbitrary request to an Azuqua API endpoint
puts azuqua.request('/flo/a22cbad4f0f9902fd7dc2e5875a8ee14/read', 'GET', { orgId: 18 })

expect(true).to eq true
```

#LICENSE - "MIT License"
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
