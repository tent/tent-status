# TentStatus

TentStatus is a Sinatra/Backbone app that sends/receives Tent status posts.

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
