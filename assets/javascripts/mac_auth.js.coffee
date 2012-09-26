class TentStatus.MacAuth
  constructor: (@options) ->
    @options = _.extend {
      time: parseInt((new Date * 1) / 1000)
      nonce: Math.random().toString(16).substring(3)
    }, @options

  signRequest: =>
    request_string = @buildRequestString()
    signature = CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA256(request_string, @options.mac_key))
    @options.request.setHeader('Authorization', @buildAuthHeader(signature))

  buildRequestString: (body=@options.body) =>
    [@options.time, @options.nonce, @options.request.method.toUpperCase(), @options.request.path, @options.request.host, @options.request.port, body, null].join("\n")

  buildAuthHeader: (signature) =>
    """
    MAC id="#{@options.mac_key_id}", ts="#{@options.time}", nonce="#{@options.nonce}", mac="#{signature}"
    """
