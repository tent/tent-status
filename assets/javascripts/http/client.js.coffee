HTTP.Client = class HTTPClient
  @urlHasValidScheme: (url = '') ->
    # has valid scheme (see https://tools.ietf.org/html/rfc3986#section-3.1)
    url.toString().match(/^[a-z][a-z0-9+.-]+:\/\//i)

  @InvalidSchemeError: (url) ->
    error = new Error(url)
    error.name = 'InvalidSchemeError'
    error

  @buildUrl: (path, hosts) =>
    return path if @urlHasValidScheme(path)
    host = hosts.shift()
    throw @InvalidSchemeError(host) unless @urlHasValidScheme(host)
    host.toString().replace(/\/$/, '') + '/' + path.replace(/^\//, '')

  constructor: (@options = {}) ->

  request: (method, path, params = {}, callback, hosts) =>
    hosts ?= _.clone(@options.hosts)
    new HTTP method, @constructor.buildUrl(path || '', hosts), _.extend({}, @options.params, params), (res, xhr) =>
      if xhr.status in [200...400]
        callback?.success?(res, xhr)
        @options.success?(res, xhr)
      else
        if hosts.length && @options.cycle
          return @request(method, path, params, callback, hosts)
        callback?.error?(res, xhr)
        @options.error?(res, xhr)

      callback?(res, xhr)
      callback?.complete?(res, xhr)
      @options.complete?(res, xhr)
    , @options.middleware

for method in ['HEAD', 'GET', 'POST', 'PUT', 'DELETE']
  do (method) ->
    HTTPClient::[method.toLowerCase()] = -> @request(method, arguments...)
