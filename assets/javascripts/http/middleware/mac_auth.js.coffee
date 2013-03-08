#= require sjcl

HTTP.Middleware ||= {}
class HTTP.Middleware.MacAuth
  constructor: (@options) ->
    @options = _.extend {
      time: parseInt((new Date * 1) / 1000)
      nonce: Math.random().toString(16).substring(3)
    }, @options

  process: (request, body) =>
    @signRequest(request, body)

  signRequest: (request, body, options = @options) =>
    request_string = @buildRequestString(request, body)
    hmac = new sjcl.misc.hmac(sjcl.codec.utf8String.toBits(options.mac_key))
    signature = sjcl.codec.base64.fromBits(hmac.mac(request_string))
    request.setHeader('Authorization', @buildAuthHeader(signature))

  buildRequestString: (request, body, options = @options) =>
    [options.time, options.nonce, request.method.toUpperCase(), request.path, request.host, request.port, null, null].join("\n")

  buildAuthHeader: (signature, options = @options) =>
    """
    MAC id="#{options.mac_key_id}", ts="#{options.time}", nonce="#{options.nonce}", mac="#{signature}"
    """
