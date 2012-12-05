class TentStatus.MacAuth
  constructor: (@options) ->
    @options = _.extend {
      time: parseInt((new Date * 1) / 1000)
      nonce: Math.random().toString(16).substring(3)
    }, @options

  signRequest: =>
    request_string = @buildRequestString()
    hmac = new sjcl.misc.hmac(sjcl.codec.utf8String.toBits(@options.mac_key))
    signature = sjcl.codec.base64.fromBits(hmac.mac(request_string))
    @options.request.setHeader('Authorization', @buildAuthHeader(signature))

  buildRequestString: (body=@options.body) =>
    [@options.time, @options.nonce, @options.request.method.toUpperCase(), @options.request.path, @options.request.host, @options.request.port, null, null].join("\n")

  buildAuthHeader: (signature) =>
    """
    MAC id="#{@options.mac_key_id}", ts="#{@options.time}", nonce="#{@options.nonce}", mac="#{signature}"
    """
