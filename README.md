# Status

**NOTE:** For a Tent v0.2 compatible version, see the [0.2](https://github.com/tent/tent-status/tree/0.2) branch.

Status is a Tent app written in JavaScript/CoffeeScript using the [Marbles.js](https://github.com/jvatic/marbles-js) framework. It supports publishing and consuming status posts.

There is an additional Ruby backend which handles authentication and serving up assets, and compiling a static version of the app.

## Getting Started

### Configuration

All configuration options can either be set through environment variables or in a `Hash` to `TentStatus.configure`.

ENV                    | Key                       | Required                                | Description
---                    | ---                       | --------                                | -----------
APP_NAME               | `:name`                   | Required                                | Name to be registered with and display in title bar.
APP_DISPLAY_URL        | `:display_url`            | Optional                                | Public URL for app (used for app registration and your server will tag posts with it). Defaults to the github url.
APP_URL                | `:url`                    | Required if running Ruby backend        | URL app is being served from (Also required if static app isn't being served from the domain root).
APP_DESCRIPTION        | `:description`            | Optional                                | Description of app (used for app registration).
APP_CDN_URL            | `:cdn_url`                | Optional                                | URL of CDN containing compiled assets.
APP_ASSET_MANIFEST     | `:asset_manifests`        | Optional                                | Comma separated paths to asset manifest JSON file (required if using a CDN).
ASSET_ROOT             | `:asset_root`             | Optional                                | Root URL or path for serving assets. Defaults to `/assets`.
PATH_PREFIX            | `:path_prefix`            | Optional                                | Path prefix for when app is mounted somewhere other than the domain root.
ADMIN_URL              | `:admin_url`              | Optional                                | URL of admin app.
DATABASE_URL           | `:database_url`           | Required if running Ruby backend        | URL of postgres database.
DATABASE_LOGFILE       | `:database_logfile`       | Optional                                | Path to file for database logging.
SESSION_SECRET         |                           | Required                                | Random string for session cookie secret.
JSON_CONFIG_URL        | `:json_config_url`        | Required if running the app statically. | URL of `config.json`.
SIGNOUT_URL            | `:signout_url`            | Required if running the app statically. | URL accepting a `POST` request to revoke access to `config.json`.
SIGNOUT_REDIRECT_URL   | `:signout_redirect_url`   | Required if running the app statically. | URL for app to redirect to after signing out.
SEARCH_API_ROOT        | `:search_api_root`        | Optional                                | Skate API root.
SEARCH_API_KEY         | `:search_api_key`         | Optional                                | Skate API key.
ENTITY_SEARCH_API_ROOT | `:entity_search_api_root` | Optional                                | URL of service to provide entity autocomplete.
SKIP_AUTHENTICATION    | `:skip_authentication`    | Optional                                | Bypasses OAuth flow when set to `true`. This only works when config.json is loaded from another source.
ASSETS_DIR             | `:public_dir`             | Optional                                | Defaults to `public/assets`.

**TODO:** Entity search service and CDN support are not currently implemented.

### Running Statically

#### config.json

Property                         | Required | Type   | Description
-------------------------------- | -------- | ------ | -----------
`credentials`                    | Required | Object | App authorization credentials.
`credentials.id`                 | Required | String | App authorization credentials identifier.
`credentials.hawk_key`           | Required | String | App authorization hawk key.
`credentials.hawk_algorithm`     | Required | String | Hash algorithm.
`meta`                           | Required | Object | Meta post content for entity.
`services.entity_search_api_key` | Optional | String | User-specific API key for entity autocomplete (`ENTITY_SEARCH_SERVICE_API_ROOT` app configuration option required for this).

**Example:**
```json
{
  "credentials": {
    "id": "HAWK-ID",
    "hawk_key": "HAWK-KEY",
    "hawk_algorithm": "sha256"
  },
  "meta": {
    // full meta post json
  }
}
```

### Running via Ruby backend

#### Heroku

```shell
heroku create --addons heroku-postgresql:dev
heroku pg:promote $(heroku pg | head -1 | cut -f2 -d" ")
heroku config:add APP_NAME='Status' \
  APP_ASSET_MANIFEST='./public/assets/manifest.json' \
  SESSION_SECRET=$(openssl rand -hex 16 | tr -d '\r\n') \
  APP_URL=$(heroku info -s | grep web_url | cut -f2 -d"=" | sed 's/http/https/' | sed 's/\/$//')
heroku labs:enable user-env-compile
git push heroku master
heroku open
```

#### Ruby

Ruby 1.9 and 2.0 supported. It has not been tested with 1.8.7.

##### OS X

The easiest way to get Ruby 1.9 or 2.0 on OS X is to use [Homebrew](http://mxcl.github.com/homebrew/).

```shell
brew install ruby
```

If you need to switch between ruby versions, use
[chruby](https://github.com/postmodern/chruby) and
[ruby-install](https://github.com/postmodern/ruby-install).


##### Ubuntu

```shell
sudo apt-get install build-essential ruby1.9.1-full libxml2 libxml2-dev libxslt1-dev
sudo update-alternatives --config ruby # make sure 1.9 is the default
```


#### PostgreSQL

tent-status requires a PostgreSQL database.

##### OS X

Use [Homebrew](http://mxcl.github.com/homebrew/) or [Postgres.app](http://postgresapp.com/).

```shell
brew install postgresql
createdb status
```


#### Bundler

Bundler is a project dependency manager for Ruby.

```
gem install bundler
```

#### ExecJS

Node.js should be installed as a javascript runtime for asset compiliation (`brew install node` on OS X).

#### Running

Clone this repository, and `cd` into the directory. This should start the app:

```shell
bundle install
DATABASE_URL=postgres://localhost/status APP_NAME='Status' SESSION_SECRET=abc APP_URL=http://localhost:3000 bundle exec puma -p 3000
```

## Contributing

Here are some tasks that need to be done:

- Add HTML5 location to posts (opt-in)
- Dim domain.com when subdomain isn't www
- Scale avatar to 16x16px and display as favicon on profile pages
- Add option to insert posts directly into the feed (rather than click 'x New Posts' bar)
- Add option to show/hide replies from people your not subscribed to
- IE compatibility
- Add pagination query string to url and reload that position when reloading the page (load specified page and show 'x Newer Posts' bar above it which should load the previous page.)
- Write tests/refactor code.

Design by [Tommi Kaikkonen](http://kaikkonendesign.fi) and [Jesse Stuart](https://github.com/jvatic).
App by [Jesse Stuart](https://github/com/jvatic)
