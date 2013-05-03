class AvatarProxyService
  constructor: (@options = {}) ->

  proxyURL: (http_url) =>
    return unless http_url
    @options.api_root + '/' + @encodeHex(http_url)

  encodeHex: (string) =>
    sjcl.codec.hex.fromBits(sjcl.codec.utf8String.toBits(string))

_.extend AvatarProxyService::, Marbles.Events
_.extend AvatarProxyService::, Marbles.Accessors

if TentStatus.config.avatar_proxy_host
  TentStatus.avatar_proxy_service = new AvatarProxyService api_root: TentStatus.config.avatar_proxy_host
