# TentStatus

TentStatus is a Sinatra/Backbone app that sends/receives Tent status posts.

## Getting Started

### Heroku

```shell
heroku create --addons heroku-postgresql:dev
heroku pg:promote $(heroku pg | head -1 | cut -f2 -d" ")
heroku config:add APP_NAME='TentStatus Standalone' STATUS_ASSET_MANIFEST='./public/assets/manifest.json' COOKIE_SECRET=abc
git push heroku master
heroku open
```

### Ruby

tent-status has only been tested with Ruby 1.9. If you don't have Ruby 1.9 you can use your
operating system's package manager to install it.

#### OS X

The easiest way to get Ruby 1.9 on OS X is to use [Homebrew](http://mxcl.github.com/homebrew/).

```shell
brew install ruby
```

If you need to switch between ruby versions, use
[rbenv](https://github.com/sstephenson/rbenv) and
[ruby-build](https://github.com/sstephenson/ruby-build).


#### Ubuntu

```shell
sudo apt-get install build-essential ruby1.9.1-full libxml2 libxml2-dev libxslt1-dev
sudo update-alternatives --config ruby # make sure 1.9 is the default
```


### PostgreSQL

tent-status requires a PostgreSQL database.

#### OS X

Use [Homebrew](http://mxcl.github.com/homebrew/) or [Postgres.app](http://postgresapp.com/).

```shell
brew install postgresql
createdb tent_status
```


### Bundler

Bundler is a project dependency manager for Ruby.

```
gem install bundler
```


### Starting tent-status

Clone this repository, and `cd` into the directory. This should start the app:

```shell
bundle install
DATABASE_URL=postgres://localhost/tent_status APP_NAME='TentStatus Standalone' COOKIE_SECRET=abc bundle exec puma -p 3000
```

There are additional ENV variables not presented above which can be configured as desired:

| name | description |
| ---- | ----------- |
| APP_ICON | URL pointing to an app icon used when creating the app in the OAuth flow |
| APP_URL | URL app your app (e.g. https://status.example.com) that is also used in the OAuth flow |
| APP_DESCRIPTION | Short description of your app that is used in the OAuth flow |
| PRIMARY_ENTITY | An entity URI used to display a profile page instead of requiring authentication |

## Contributing

The app currently isn't very useful because it needs OAuth authentication so
that it can talk to Tent servers.

Here are some tasks that need to be done:

- Integrate with [omniauth-tent](https://github.com/tent/omniauth-tent)
- Add HTML5 location to posts (opt-in)
- Fix replies to mentions when on the mentions page from inserting into the feed
- Make navbar sticky (visible when scrolling)
- Add inline conversation view (or a modal which renders the existing one)
- Add new post form to profile page (should be pre-filled with mention)
- Show location and other data from basic profile on the profile page
- Dim domain.com when subdomain isn't www
- Show number of unread posts in parens in page title
- Add permissions field (including public checkbox) (see [new_post_form.js.coffee](https://github.com/tent/tent-status/blob/master/assets/javascripts/views/new_post_form.js.coffee#L42-80))
- Scale avatar to 16x16px and display as favicon on profile pages
- Add section to view who reposted your posts
- Collapse multiple reposts of the same post into a single post with multiple names/avatars listed at the bottom
- Make it clear which followers are recent on followers page
- Mark nav items selected (add 'active' class)
- Add pluralizations (e.g. '1 Post', '6 Posts')
- Timestamps on single post view should show full date
- Add option to insert posts directly into the feed (rather than click 'x New Posts' bar)
- Add option to show/hide replies from people your not following
- IE compatibility
- Add pagination query string to url and reload that position when reloading the page (load specified page and show 'x Newer Posts' bar above it which should load the previous page.)
- Add full mobile compatibility (fix JavaScript issues on mobile browsers, use bootstrap mobile menu, etc.)
- Write tests/refactor code.
- Make it pretty.



1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Setup notes

It's expected that Node.js be installed as a javascript runtime (`brew install node` on OS X)

