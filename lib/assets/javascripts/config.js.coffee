#= require ./static_config
#= require_self

window.TentStatus ?= {}

unless TentStatus.config.JSON_CONFIG_URL
	throw "json_config_url is required!"

new Marbles.HTTP(
  method: 'GET'
  url: TentStatus.config.JSON_CONFIG_URL
  middleware: [{
    processRequest: (request) ->
      request.request.xmlhttp.withCredentials = true
  }]
  callback: (res, xhr) ->
    if xhr.status != 200
      return setImmediate =>
        throw "failed to load json config via GET #{TentStatus.config.JSON_CONFIG_URL}: #{xhr.status} #{JSON.stringify(res)}"

    TentStatus.config ?= {}
    for key, val of JSON.parse(res)
      TentStatus.config[key] = val

    TentStatus.config.authenticated = !!TentStatus.config.credentials

    # TODO: handle subdomains for hosted version via window.location.href
    TentStatus.config.domain_entity ?= TentStatus.config.meta?.entity

    TentStatus.tent_client = new TentClient(
      TentStatus.config.meta.content.entity,
      credentials: TentStatus.config.credentials
      server_meta_post: TentStatus.config.meta
    )

    TentStatus.config_ready = true
    TentStatus.trigger?('config:ready')
)

