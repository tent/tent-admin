# TentAdmin

Admin app compatible with Tent v0.3.

## Installation

Add this line to your application's Gemfile:

    gem 'tent-admin', :git => 'git://github.com/tent/tent-admin.git', :branch => 'master'

And then execute:

    $ bundle

## Usage

### Mounting in an existing Rack app

```
createdb tent-admin
```

```ruby
require 'tent-admin'

map '/admin' do
  run TentAdmin.new(:database_url => 'postgres://localhost/tent-admin', :database_logfile => STDOUT)
end
```

### Running on it's own

```
createdb tent-admin
DATABASE_URL=postgres://localhost/tent-admin bundle exec puma
```

### ENV variables

name | required | description
---- | -------- | -----------
URL | Yes | URL app is mounted at
DATABASE_URL | Yes | Postgres Database URL
DATABASE_LOGFILE | No | Path or `IO` for database log
SESSION_SECRET | Yes | Session secret

### Options

`database_url`, and `database_logfile` options can be passed to `TentAdmin.new` to override the coresponding ENV

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
