moment.relativeTime = {
  future: "in %s",
  past: "%s",
  s: "%ds",
  m: "1m",
  mm: "%dm",
  h: "1h",
  hh: "%dh",
  d: "1d",
  dd: "%dd",
  M: "1mo",
  MM: "%dmo",
  y: "ay",
  yy: "%dy"
}

window.TentStatus ?= {}
TentStatus.config = {
  POST_TYPES:
    META: "https://tent.io/types/meta/v0#"
    FOLLOWER: 'https://tent.io/types/relationship/v0#follower'
    FOLLOWING: 'https://tent.io/types/relationship/v0#following'
    STATUS: 'https://tent.io/types/status/v0#'
    STATUS_REPLY: 'https://tent.io/types/status/v0#reply'
    WILDCARD_STATUS: 'https://tent.io/types/status/v0'
    REPOST: 'https://tent.io/types/repost/v0'
    STATUS_REPOST: 'https://tent.io/types/repost/v0#https://tent.io/types/status/v0'
    REPLIES_CURSOR: 'https://tent.io/types/cursor/v0#https://tent.io/rels/status-replies'
    FEED_CURSOR: 'https://tent.io/types/cursor/v0#https://tent.io/rels/status-feed'
    SUBSCRIPTION: 'https://tent.io/types/subscription/v0#'
    STATUS_SUBSCRIPTION: 'https://tent.io/types/subscription/v0#https://tent.io/types/status/v0'
    REPOST_SUBSCRIPTION: 'https://tent.io/types/subscription/v0#https://tent.io/types/repost/v0'
    WILDCARD_SUBSCRIPTION: 'https://tent.io/types/subscription/v0#all'
  PER_PAGE: 20
  CONVERSATION_PER_PAGE: 10
  FETCH_INTERVAL: 3000
  MAX_FETCH_LATENCY: 30000
  URL_TRIM_LENGTH: 30
  MAX_STATUS_LENGTH: 256
}

TentStatus.config.PLACEHOLDER_AVATAR_URL = TentStatus.config.DEFAULT_AVATAR_URL

TentStatus.config.repost_types = [
  TentStatus.config.POST_TYPES.STATUS_REPOST,
]

TentStatus.config.feed_types = [
  TentStatus.config.POST_TYPES.STATUS
].concat(TentStatus.config.repost_types)

TentStatus.config.subscription_feed_types = [
  TentStatus.config.POST_TYPES.STATUS_SUBSCRIPTION,
  TentStatus.config.POST_TYPES.REPOST_SUBSCRIPTION,
  TentStatus.config.POST_TYPES.WILDCARD_SUBSCRIPTION
]

TentStatus.config.subscription_types = [
  TentStatus.config.POST_TYPES.WILDCARD_STATUS,
  TentStatus.config.POST_TYPES.STATUS_REPOST
]

json_config_url = Marbles.DOM.attr(document.body, 'data-config-url')
unless json_config_url
	throw "data-config-url must be set on <body> and point to a valid json config file"

new Marbles.HTTP(
	method: 'GET'
	url: json_config_url
	callback: (res, xhr) ->
    if xhr.status != 200
      throw "failed to load json config via GET #{json_config_url}: #{xhr.status} #{JSON.stringify(res)}"

    TentStatus.config ?= {}
    for key, val of JSON.parse(res)
      TentStatus.config[key] = val

    TentStatus.config.authenticated = !!TentStatus.config.current_user

    TentStatus.tent_client = new TentClient(
      TentStatus.config.current_user.entity,
      credentials: TentStatus.config.current_user.credentials
      server_meta_post: TentStatus.config.current_user.server_meta_post
    )

    TentStatus.config_ready = true
    TentStatus.trigger?('config:ready')
)

