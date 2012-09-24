class @HTTP
  @active_requests: {}

  constructor: (@method, @url, @data, callback) ->
    @key = "#{@method}:#{@url}:#{JSON.stringify(@data || '{}')}"
    if request = HTTP.active_requests[@key]
      return request.callbacks.push(callback)
    else
      HTTP.active_requests[@key] = @

    @callbacks = if callback then [callback] else []

    @request = new HTTP.Request

    if @method == 'GET'
      params = ("#{encodeURIComponent(k)}=#{encodeURIComponent(v)}" for k,v of @data)
      separator = if @url.match(/\?/) then "&" else "?"
      @url += "#{separator}#{params.join('&')}" if params.length
      @data = null

    uri = new HTTP.URI @url
    @host = uri.hostname
    @path = uri.path
    @port = uri.port

    @sendRequest()

  setHeader: => @request.setHeader(arguments...)
  sendRequest: =>
    return unless @request

    @request.open(@method, @url)

    data = if @data then JSON.stringify(@data) else null
    data = null if data == "{}" or data == "[]"

    if data && ["POST", "PUT", "PATCH"].indexOf(@method.toUpperCase()) != -1
      @request.setHeader('Content-type','application/vnd.tent.v0+json')

    uri = new HTTP.URI @url
    if TentStatus.current_auth_details.mac_key and uri.hostname == TentStatus.config.current_entity.hostname
      (new TentStatus.MacAuth
        request: @
        body: data
        mac_key: TentStatus.current_auth_details.mac_key
        mac_key_id: TentStatus.current_auth_details.mac_key_id
      ).signRequest()

    @request.on 'complete', (xhr) =>
      delete HTTP.active_requests[@key]
      data = if xhr.status == 200 and xhr.response then JSON.parse(xhr.response) else null
      for fn in @callbacks
        continue unless typeof fn == 'function'
        fn(data, xhr)

    @request.send(data)

  class @URI
    constructor: (@url) ->
      return @url if @url.isURI

      m = @url.match(/^(https?:\/\/)?([^\/]+)?(.*)$/)
      h = m[2]?.split(':')
      @scheme = m[1] or (window.location.protocol + '//')
      @hostname = if h then h[0] else window.location.hostname
      @port = parseInt(h[1]) if h and h[1]
      if @hostname == window.location.hostname and window.location.port
        @port = parseInt(window.location.port)
      if !@port
        @port ?= if @scheme.match(/^https/) then 443 else 80
      @path = m[3]
      @base_host = _.last(@hostname.split('.'))

      @isURI = true

    toString: =>
      (@scheme + @hostname + ':' + @port + @path).replace(/\/$/, '')

    toStringWithoutSchemePort: =>
      if [443, 80].indexOf(@port) != -1
        port_string = ''
      else
        port_string = ':' + @port

      (@scheme + @hostname + port_string + @path).replace(/\/$/, '')

    assertEqual: (uri_or_string) =>
      unless uri_or_string.isURI
        uri = new HTTP.URI uri_or_string
      else
        uri = uri_or_string
      (uri.scheme == @scheme) and (uri.hostname == @hostname) and (uri.port == @port) and (uri.path == @path)

  class @Request
    constructor: ->
      @callbacks = {}

      XMLHttpFactories = [
        -> new XMLHttpRequest()
        -> new ActiveXObject("Msxml2.XMLHTTP")
        -> new ActiveXObject("Msxml3.XMLHTTP")
        -> new ActiveXObject("Microsoft.XMLHTTP")
      ]

      @xmlhttp = false
      for fn in XMLHttpFactories
        try
          @xmlhttp = fn()
        catch e
          continue
        break

      @xmlhttp.onreadystatechange = @stateChanged

    stateChanged: =>
      return if @xmlhttp.readyState != 4
      @trigger 'complete'

    setHeader: (key, val) => @xmlhttp.setRequestHeader(key,val)

    on: (eventName, fn) =>
      @callbacks[eventName] ||= []
      @callbacks[eventName].push fn

    trigger: (eventName) =>
      @callbacks[eventName] ||= []
      for fn in @callbacks[eventName]
        if typeof fn == 'function'
          fn(@xmlhttp)
        else
          console?.warn "#{eventName} callback is not a function"
          console?.log fn

    open: (method, url) => @xmlhttp.open(method, url, true)

    send: (data) =>
      return @trigger('complete') if @xmlhttp.readyState == 4
      @xmlhttp.send(data)
