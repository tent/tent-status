#= require hmac_sha256

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
    signature = CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA256(request_string, options.mac_key))
    request.setHeader('Authorization', @buildAuthHeader(signature))

  buildRequestString: (request, body, options = @options) =>
    [options.time, options.nonce, request.method.toUpperCase(), request.path, request.host, request.port, null, null].join("\n")

  buildAuthHeader: (signature, options = @options) =>
    """
    MAC id="#{options.mac_key_id}", ts="#{options.time}", nonce="#{options.nonce}", mac="#{signature}"
    """
