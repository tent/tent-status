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
        throw "failed to load json config via GET #{json_config_url}: #{xhr.status} #{JSON.stringify(res)}"

    TentStatus.config ?= {}
    for key, val of JSON.parse(res)
      TentStatus.config[key] = val

    TentStatus.config.authenticated = !!TentStatus.config.current_user

    # TODO: handle subdomains for hosted version via window.location.href
    TentStatus.config.domain_entity ?= TentStatus.config.current_user?.entity

    TentStatus.tent_client = new TentClient(
      TentStatus.config.current_user.entity,
      credentials: TentStatus.config.current_user.credentials
      server_meta_post: TentStatus.config.current_user.server_meta_post
    )

    TentStatus.config_ready = true
    TentStatus.trigger?('config:ready')
)

