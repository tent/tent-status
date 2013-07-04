# Status

**NOTE:** For a Tent v0.2 compatible version, see the [0.2](https://github.com/tent/tent-status/tree/0.2) branch.

Status is a Tent app written in JavaScript/CoffeeScript using the [Marbles.js](https://github.com/jvatic/marbles-js) framework. It supports publishing and consuming status posts.

There is an additional Ruby backend which handles authentication and serving up assets, and compiling a static version of the app.

## Getting Started

### Configuration

All configuration options can either be set through environment variables or in a `Hash` to `TentStatus.configure`.

Configuration options prefixed with `APP_` are only useful when using the Ruby backend (with the exception of `APP_NAME`).

ENV                    | Key                       | Required                                | Description
---                    | ---                       | --------                                | -----------
APP_NAME               | `:name`                   | Required                                | Name to be registered with and display in title bar.
APP_ICON_URL_BASE      | `:icon_url_base`          | Optional                                | Base URL for `appicon57.png` (57x57), `appicon72.png` (72x72), `appicon114.png` (114x114), and `favicon.png` (16x16).
APP_URL                | `:url`                    | Required if running Ruby backend        | URL app is being served from (Also required if static app isn't being served from the domain root).
APP_DESCRIPTION        | `:description`            | Optional                                | Description of app (used for app registration).
APP_CDN_URL            | `:cdn_url`                | Optional                                | URL of CDN containing compiled assets.
APP_ASSET_MANIFEST     | `:asset_manifest`         | Optional                                | Path to asset manifest JSON file (required if using a CDN).
ADMIN_URL              | `:admin_url`              | Optional                                | URL of admin app.
DATABASE_URL           | `:database_url`           | Required if running Ruby backend        | URL of postgres database.
DATABASE_LOGFILE       | `:database_logfile`       | Optional                                | Path to file for database logging.
SESSION_SECRET         |                           | Required                                | Random string for session cookie secret.
                       | `:public_dir`             | Optional                                | Path to directory containing compiled assets (defaults to `./public/assets`).
JSON_CONFIG_URL        | `:json_config_url`        | Required if running the app statically. | URL of `config.json`.
SIGNOUT_URL            | `:signout_url`            | Required if running the app statically. | URL accepting a `POST` request to revoke access to `config.json`.
SIGNOUT_REDIRECT_URL   | `:signout_redirect_url`   | Required if running the app statically. | URL for app to redirect to after signing out.
DEFAULT_AVATAR_URL     | `:default_avatar_url`     | Required                                | URL of image to display when avatar for an entity is unavailable.
AVATAR_PROXY_HOST      | `:avatar_proxy_host`      | Optional                                | URL of service to proxy non-https avatars through an https connection.
SEARCH_API_ROOT        | `:search_api_root`        | Optional                                | Skate API root.
SEARCH_API_KEY         | `:search_api_key`         | Optional                                | Skate API key.
ENTITY_SEARCH_API_ROOT | `:entity_search_api_root` | Optional                                | URL of service to provide entity autocomplete.

**TODO:** Entity search service and CDN support are not currently implemented.

### Running Statically

#### config.json

Property                                  | Required | Type   | Description
----------------------------------------- | -------- | ------ | -----------
`current_user`                            | Required | Object | User data.
`current_user.credentials`                | Required | Object | App authorization credentials.
`current_user.credentials.id`             | Required | String | App authorization credentials identifier.
`current_user.credentials.hawk_key`       | Required | String | App authorization hawk key.
`current_user.credentials.hawk_algorithm` | Required | String | Hash algorithm.
`current_user.entity`                     | Required | String | Entity URI.
`current_user.server_meta_post`           | Required | Object | Meta post for entity.
`services.entity_search_api_key`          | Optional | String | User-specific API key for entity autocomplete (`ENTITY_SEARCH_SERVICE_API_ROOT` app configuration option required for this).

**Example:**
```json
{
  "current_user": {
    "credentials": {
      "id": "HAWK-ID",
      "hawk_key": "HAWK-KEY",
      "hawk_algorithm": "sha256"
    },
    "entity": "https://example.org",
    "server_meta_post": {}
  }
}
```

### Running via Ruby backend

#### Heroku

```shell
heroku create --addons heroku-postgresql:dev
heroku pg:promote $(heroku pg | head -1 | cut -f2 -d" ")
heroku config:add APP_NAME='Status' APP_ASSET_MANIFEST='./public/assets/manifest.json' SESSION_SECRET=$(openssl rand -hex 16 | tr -d '\r\n')
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

**Note:** Not compatible with CoffeeScript 1.6.x, only tested with 1.3.3

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
