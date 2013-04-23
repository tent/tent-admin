# TentAdmin

Admin app compatible with Tent v0.3.

## Installation

Add this line to your application's Gemfile:

    gem 'tent-admin', :git => 'git://github.com/tent/tent-admin.git', :branch => 'master'

And then execute:

    $ bundle

## Usage

### Mounting in an existing Rack app

```ruby
require 'tent-admin'

map '/admin' do
  run TentAdmin.new
end
```

### Running on it's own

```bash
bundle exec puma
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
