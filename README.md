Azuqua Ruby client
=====================

[PLACEHOLDER_DESC_HERE]

Requirements
============

Ruby > 2.4

Install
=======

Add the gem as a dependency

```ruby
gem 'azuqua', :git => 'git@github.com:azuqua/azuqua.rb.git', :branch => 'apiV2'
```

Usage
=====
```ruby
# Load accessKey & accessSecret via environment variables
# Checks for variables `AZUQUA_ACCESS_KEY` and `AZUQUA_ACCESS_SECRET` respectivly
azuqua = Azuqua.from_env()

# Alternativly to load from a JSON file with { accessKey: "", accessSecret: "" }
# azuqua = Azuqua.from_config([PATH])

# OR - call initialize new azuqua passing in key and secret to constructor
# azuqua = Azuqua.new([KEY], [SECRET])



puts(azuqua.read_all_accounts())


puts(azuqua.read_account(account_id))


puts(azuqua.delete_account(account_id))


data = {
  :role => "NONE"
}
puts(azuqua.update_account_user_permissions(account_id, user_id, data))


puts(azuqua.read_connector_version(connector_name, connector_version))


puts(azuqua.read_flo(flo_id))


data = {
  :name => "",
  :description => ""
}
puts(azuqua.update_flo(flo_id, data))


puts(azuqua.delete_flo(flo_id))


puts(azuqua.enable_flo(flo_id))


puts(azuqua.disable_flo(flo_id))


puts(azuqua.read_flo_inputs(flo_id))


puts(azuqua.read_flo_accounts(flo_id))


puts(azuqua.move_flo_to_folder(flo_id, folder_id))


data = {
  :configs => "",
  :inputs => [],
  :outputs => []
}
puts(azuqua.modify_flo(flo_id, data))


data = {
  :folder_id => 0
}
puts(azuqua.copy_flo(flo_id, data))


data = {
  :folder_id => 0
}
puts(azuqua.copy_flo_to_org(flo_id, org_id, data))


puts(azuqua.read_all_folders())


data = {
  :name => "",
  :description => ""
}
puts(azuqua.create_folder(data))


puts(azuqua.read_folder(folder_id))


data = {
  :name => "",
  :description => ""
}
puts(azuqua.update_folder(folder_id, data))


puts(azuqua.delete_folder(folder_id))


puts(azuqua.read_folder_flos(folder_id))


puts(azuqua.read_folder_users(folder_id))


data = {
  :role => "NONE"
}
puts(azuqua.update_folder_user_permissions(folder_id, user_id, data))


puts(azuqua.read_org())


data = {
  :name => "",
  :display_name => ""
}
puts(azuqua.update_org(data))


puts(azuqua.read_org_flos())


puts(azuqua.read_org_connectors())


puts(azuqua.remove_user_from_org(user_id))


data = {
  :role => "MEMBER"
}
puts(azuqua.update_org_user_permissions(user_id, data))


puts(azuqua.read_user_orgs())
```

LICENSE - "MIT License"
=======================
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
