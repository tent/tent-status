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

@TentStatus ?= {}
TentStatus.config ?= {}
_.extend TentStatus.config, {
  POST_TYPES:
    BASIC_PROFILE: 'https://tent.io/types/basic-profile/v0#'
    FOLLOWER: 'https://tent.io/types/relationship/v0#follower'
    FOLLOWING: 'https://tent.io/types/relationship/v0#following'
    STATUS: 'https://tent.io/types/status/v0#'
    STATUS_REPLY: 'https://tent.io/types/status/v0#reply'
    REPOST: 'https://tent.io/types/repost/v0#'
    MENTIONS_CURSOR: 'https://tent.io/types/cursor/v0#https://tent.io/rels/status-mentions'
    FEED_CURSOR: 'https://tent.io/types/cursor/v0#https://tent.io/rels/status-feed'
  PER_PAGE: 20
  CONVERSATION_PER_PAGE: 10
  FETCH_INTERVAL: 3000
  MAX_FETCH_LATENCY: 30000
  URL_TRIM_LENGTH: 30
  MAX_STATUS_LENGTH: 256
}

TentStatus.config.PLACEHOLDER_AVATAR_URL = TentStatus.config.DEFAULT_AVATAR_URL

TentStatus.config.authenticated = !!TentStatus.config.current_user

TentStatus.config.feed_types = [
  TentStatus.config.POST_TYPES.STATUS
  TentStatus.config.POST_TYPES.REPOST
]

