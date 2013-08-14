#= require ./static_config
#= require_self

window.TentStatus ?= {}

unless TentStatus.config.JSON_CONFIG_URL
	throw "json_config_url is required!"

new Marbles.HTTP(
  method: 'GET'
  url: TentStatus.config.JSON_CONFIG_URL
  middleware: [Marbles.HTTP.Middleware.WithCredentials]
  callback: (res, xhr) ->
    if xhr.status != 200
      if xhr.status == 401
        return window.location.href = TentStatus.config.SIGNOUT_REDIRECT_URL

      return setImmediate =>
        throw "failed to load json config via GET #{TentStatus.config.JSON_CONFIG_URL}: #{xhr.status} #{JSON.stringify(res)}"

    TentStatus.config ?= {}
    for key, val of JSON.parse(res)
      TentStatus.config[key] = val

    TentStatus.config.authenticated = !!TentStatus.config.credentials

    TentStatus.tent_client = new TentClient(
      TentStatus.config.meta.content.entity,
      credentials: TentStatus.config.credentials
      server_meta_post: TentStatus.config.meta
    )

    TentStatus.config_ready = true
    TentStatus.trigger?('config:ready')
)

