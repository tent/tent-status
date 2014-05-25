# Micro

**NOTE:** For a Tent v0.2 compatible version, see the [0.2](https://github.com/tent/tent-status/tree/0.2) branch.

This is a Tent app for micro blogging. It's built with [React](http://reactjs.org) and [Marbles.js](https://github.com/jvatic/marbles-js).

## Getting Started

### Configuration

ENV                   | Required | Description
---                   | -------- | -----------
`APP_URL`             | Required | URL app is mounted at.
`ASSET_ROOT`          | Optional | Root URL or path for serving assets. Defaults to `/assets`.
`ASSET_CACHE_DIR`     | Optional | Filesystem path for sprockets asset cache directory.
`ASSETS_DIR`          | Optional | Defaults to `public/assets`.
`LAYOUT_DIR`          | Optional | Defaults to `public`.
`PATH_PREFIX`         | Optional | Path prefix for when app is mounted somewhere other than the domain root.
`JSON_CONFIG_URL`     | Required | URL of `config.json`.
`LOGOUT_URL`          | Required | URL accepting a `POST` request to revoke access to `config.json`.
`LOGOUT_REDIRECT_URL` | Required | URL for app to redirect to after signing out.
`LOGIN_URL`           | Required | URL accepting a `POST` request with `username` and `passphrase` to grant access to `config.json`. (User is redirected to `LOGOUT_REDIRECT_URL` instead of displaying an auth form if not specified.)
`SEARCH_API_ROOT`     | Optional | Skate API root.
`SEARCH_API_KEY`      | Optional | Skate API key.
`DEFAULT_AVATAR_ROOT` | Optional | Defaults to a static avatar. If set, appending `"/" + encodeURIComponent(entity)` should point to a unique avatar for that entity (see [Sigil](https://github.com/cupcake/sigil) for more information).
`CONTACTS_URL`        | Required | URL of [contacts service](https://github.com/cupcake/contacts-service) instance.

#### JSON config

```
{
  "credentials": {
    "id": "...",
    "hawk_key": "...",
    "hawk_algorithm": "sha256"
  }, // app auth credentials
  "meta": { ... } // meta post JSON of authenticated entity
}
```

(Must be available via `JSON_CONFIG_URL`, don't forget to setup CORS.)

**NOTE:** You don't actually need `LOGIN_URL`, `LOGOUT_URL`, or `LOGOUT_REDIRECT_URL` if `JSON_CONFIG_URL` does not require authentication (e.g. when running locally).

### Running statically

You will need Node.js as a JavaScript runtime for compilation (`brew install node` on OS X).

Ensure any env vars you need are set when running `rake compile`:

```
APP_URL=http://localhost:8000 bundle exec rake compile
```

```
cd public
python -m SimpleHTTPServer
```

Open [localhost:8000](http://localhost:8000).

### Running in development mode

```
APP_URL=http://localhost:3000 bundle exec puma -p 3000
```

## Contributing

The new version of the app currently being worked on is using a [Flux](http://facebook.github.io/react/docs/flux-overview.html)-like architecture.

Open an issue before implementing a feature to ensure it's not already being worked on and fits the scope of the application.

Design by [Tommi Kaikkonen](http://kaikkonendesign.fi) and [Jesse Stuart](https://github.com/jvatic).
App by [Jesse Stuart](https://github/com/jvatic)
