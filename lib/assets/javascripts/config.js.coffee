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
      # Redirect to signin

      setImmediate ->
        TentStatus.run(history: { silent: true })

        fragment = Marbles.history.getFragment()
        if fragment.match /^signin/
          Marbles.history.navigate(fragment, trigger: true, replace: true)
        else
          if fragment == ""
            Marbles.history.navigate("/signin", trigger: true)
          else
            Marbles.history.navigate("/signin?redirect=#{encodeURIComponent(Marbles.history.getFragment())}", trigger: true)

      return

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

