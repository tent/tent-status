class TentStatus.MacAuth
  constructor: (@options) ->
    @options = _.extend {
      time: parseInt((new Date * 1) / 1000)
      nonce: Math.random().toString(16).substring(3)
    }, @options

  signRequest: =>
    request_string = @buildRequestString()
    console.log JSON.stringify(request_string)
    signature = (new jsSHA(request_string, 'ASCII')).getHMAC(@options.mac_key, "ASCII", "SHA-256", "B64")
    @options.request.setHeader('Authorization', @buildAuthHeader(signature))

  buildRequestString: (body=@options.body) =>
    [@options.time, @options.nonce, @options.request.method.toUpperCase(), @options.request.path, @options.request.host, @options.request.port, body, null].join("\n")

  buildAuthHeader: (signature) =>
    """
    MAC id="#{@options.mac_key_id}", ts="#{@options.time}", nonce="#{@options.nonce}", mac="#{signature}"
    """
