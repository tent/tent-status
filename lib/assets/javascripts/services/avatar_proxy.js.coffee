class AvatarProxyService
  constructor: (@options = {}) ->

  proxyURL: (http_url) =>
    return unless http_url
    @options.api_root + '/' + @encodeHex(http_url)

  encodeHex: (string) =>
    sjcl.codec.hex.fromBits(sjcl.codec.utf8String.toBits(string))

_.extend AvatarProxyService::, Marbles.Events
_.extend AvatarProxyService::, Marbles.Accessors

if (api_root = TentStatus.config.avatar_proxy_host)
  TentStatus.services ?= {}
  TentStatus.services.avatar_proxy = new AvatarProxyService api_root: api_root

