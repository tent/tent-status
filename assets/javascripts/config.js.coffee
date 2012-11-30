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
  M: "1 mon",
  MM: "%d mon",
  y: "a year",
  yy: "%d years"
}

@TentStatus ?= {}
TentStatus.config ?= {}
_.extend TentStatus.config, {
  tent_host_api_root: TentStatus._config.tent_host_api_root
  tent_api_root: new HTTP.URI(TentStatus._config.tent_api_root) if TentStatus._config.tent_api_root
  current_tent_api_root: new HTTP.URI(TentStatus._config.domain_tent_api_root) if TentStatus._config.domain_tent_api_root
  tent_host_domain: TentStatus._config.tent_host_domain
  tent_host_domain_tent_api_path: '/tent'
  tent_proxy_root: new HTTP.URI(TentStatus._config.tent_proxy_root)
  domain_entity: new HTTP.URI(TentStatus._config.domain_entity) if TentStatus._config.domain_entity
  domain_tent_api_root: new HTTP.URI(TentStatus._config.domain_tent_api_root) if TentStatus._config.domain_tent_api_root
  current_entity: new HTTP.URI(TentStatus._config.current_entity) if TentStatus._config.current_entity
  POST_TYPES:
    STATUS: 'https://tent.io/types/post/status/v0.1.0'
    REPOST: 'https://tent.io/types/post/repost/v0.1.0'
  PER_PAGE: 20
  FETCH_INTERVAL: 3000
  MAX_FETCH_LATENCY: 30000
  URL_TRIM_LENGTH: 30
  MAX_LENGTH: 256
  default_avatar: 'http://dr49qsqhb5y4j.cloudfront.net/default1.png'
  CORE_PROFILE_TYPE: 'https://tent.io/types/info/core/v0.1.0'
  BASIC_PROFILE_TYPE: 'https://tent.io/types/info/basic/v0.1.0'
  TENT_STATUS_PROFILE_TYPE: 'https://tent.io/types/info/tent-status/v0.1.0'
  BASE_TITLE: document.title
}

TentStatus.config.post_types = [TentStatus.config.POST_TYPES.STATUS, TentStatus.config.POST_TYPES.REPOST]

for k,v of TentStatus._config
  TentStatus.config[k] = v unless TentStatus.config.hasOwnProperty(k)

delete TentStatus._config

TentStatus.config.guest = !TentStatus.config.authenticated || !TentStatus.config.current_entity.assertEqual(TentStatus.config.domain_entity)
TentStatus.config.app_domain = TentStatus.config.tent_host_domain and window.location.hostname == "app.#{TentStatus.config.tent_host_domain}"

