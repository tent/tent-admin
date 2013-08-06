# TentAdmin

Admin app compatible with Tent v0.3.

### Configuration

Name                 | Key                     | Required | Description
-------------------- | ----------------------- | -------- | -----------
SESSION_SECRET       |                         | Required | Random string for session secret.
URL                  | `:url`                  | Required | URL app is mounted at.
DATABASE_URL         | `:database_url`         | Required | Postgres database URL for app.
DATABASE_LOGFILE     | `:database_logfile`     | Optional | File path or `IO` for database log. Defaults to STDOUT.
APP_NAME             | `:name`                 | Optional | Name of app used for app registration.
APP_DESCRIPTION      | `:description`          | Optional | Description of app used for app registration.
APP_DISPLAY_URL      | `:display_url`          | Optional | URL app is registered with (_doesn't_ have to be the same as `URL`).
STATUS_URL           | `:status_url`           | Optional | URL of status app (adds a link in the global nav).
SEARCH_URL           | `:search_url`           | Optional | URL of search app (adds a link in the global nav).
PATH_PREFIX          | `:path_prefix`          | Optional | Path prefix if app isn't mounted at the domain root.
ASSET_ROOT           | `:asset_root`           | Optional | Root URL where assets are served from. Defaults to `/assets`.
JSON_CONFIG_URL      | `:json_config_url`      | Optional | URL where `config.json` is served from. Defaults to `/config.json`.
SIGNOUT_URL          | `:signout_url`          | Optional | URL where sign-out action is located. Defaults to `/signout`.
SIGNOUT_REDIRECT_URL | `:signout_redirect_url` | Optional | URL to redirect to after signing out.
APP_ASSET_MANIFEST   |                         | Optional | File path to existing JSON asset manifest.
SKIP_AUTHENTICATION  | `:skip_authentication`  | Optional | Bypasses OAuth flow when set to `true`. This only works when config.json is loaded from another source.

### Running on it's own

```shell
git clone git://github.com/tent/tent-admin.git
createdb tent-admin
DATABASE_URL=postgres://localhost/tent-admin URL=http://localhost:9292 bundle exec puma -p 9292
```

### Heroku

```shell
heroku create --addons heroku-postgresql:dev
heroku pg:promote $(heroku pg | head -1 | cut -f2 -d" ")
heroku config:add APP_ASSET_MANIFEST='./public/assets/manifest.json' SESSION_SECRET=$(openssl rand -hex 16 | tr -d '\r\n')
git push heroku master
heroku open
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
