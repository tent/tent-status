_.extend TentStatus.Helpers,
  assertUrlHostsMatch: (url, other_url) ->
    uri = new Marbles.HTTP.URI(url)
    other_uri = new Marbles.HTTP.URI(other_url)

    (other_uri.hostname == uri.hostname) &&
    (other_uri.port == uri.port) &&
    (other_uri.scheme == uri.scheme)

  ensureUrlHasScheme: (url) ->
    return unless url
    return url if url.match /^[a-z]+:\/\//i
    return url if url.match /^\// # relative
    'http://' + url

  isAppDomain: ->
    @assertUrlHostsMatch(window.location.href, TentStatus.config.APP_URL)

  isURLExternal: (url) ->
    return false unless url
    return false if url.match(/^\//)

    !@assertUrlHostsMatch(window.location.href, url)

  isCurrentUserEntity: (entity) ->
    return false unless TentStatus.config.meta
    uri = new Marbles.HTTP.URI(TentStatus.config.meta.content.entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )

