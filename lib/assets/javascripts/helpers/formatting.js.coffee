_.extend TentStatus.Helpers,
  formatTime: (timestamp_int) ->
    now = moment()
    time = moment(timestamp_int)

    formatted_time = if time.format('YYYY-MM-DD') == now.format('YYYY-MM-DD')
      time.format('HH:mm') # time only
    else
      time.format('DD-MMM-YY') # date and time

    "#{formatted_time}"

  formatRelativeTime: (timestamp_int) ->
    now = moment()
    time = moment(timestamp_int)

    formatted_time = time.fromNow()

    "#{formatted_time}"

  rawTime: (timestamp_int) ->
    moment(timestamp_int).format()

  formatCount: (count, options = {}) ->
    return count unless options.max && count > options.max
    "#{options.max}+"

  shortType: (type_uri) ->
    type_uri?.match(/([^\/]+)\/v[\d.]+/)?[1]

  minimalEntity: (entity) ->
    return unless entity
    if TentStatus.config.tent_host_domain && entity.match(new RegExp("([a-z0-9]{2,})\.#{TentStatus.config.tent_host_domain}"))
      RegExp.$1
    else
      entity

  formatUrl: (url='') ->
    url.replace(/^\w+:\/\/([^\/]+).*?$/, '$1')

  formatUrlWithPath: (url = '') ->
    url.replace(/^\w+:\/\/(.*)$/, '$1')

  capitalize: (string) ->
    string.substr(0, 1).toUpperCase() + string.substr(1, string.length)

  pluralize: (word, count, plural) ->
    if count is 1 || count is -1
      word
    else
      plural

  replaceIndexRange: (start_index, end_index, string, replacement) ->
    string.substr(0, start_index) + replacement + string.substr(end_index, string.length-1)

  # HTML escaping
  HTML_ENTITIES: {
    '&': '&amp;',
    '>': '&gt;',
    '<': '&lt;',
    '"': '&quot;',
    "'": '&#39;'
  }
  htmlEscapeText: (text) ->
    return unless text
    text.replace /[&"'><]/g, (character) -> TentStatus.Helpers.HTML_ENTITIES[character]

  htmlUnescapeText: (text) ->
    for char, entities of HTML_ENTITIES
      text = text.replace(entities, char)
    text

  extractTrailingHtmlEntitiesFromText: (text) ->
    trailing_text = ""
    for char, entities of TentStatus.Helpers.HTML_ENTITIES
      regex = new RegExp("(#{TentStatus.Helpers.escapeRegExChars(entities)}?)$")
      if regex.test(text)
        trailing_text = text.match(regex)[1] + trailing_text
        text = text.replace(regex, "")
    [text, trailing_text]

  sanitizeAvatarUrl: (url='') ->
    return unless url.match(/^https?:\/\//)
    url

  truncate: (text, length, elipses='...') ->
    return text unless text
    if text.length > length
      _truncated = text.substr(0, length-elipses.length)
      _truncated += elipses
    else
      _truncated = text
    _truncated

  formatTentMarkdown: (text = '', mentions = []) ->
    externalLinkPreprocessor = (jsonml) ->
      return jsonml unless jsonml[0] is 'link'
      return jsonml unless TentStatus.Helpers.isURLExternal(jsonml[1]?.href)
      jsonml[1]['data-view'] = 'ExternalLink'
      jsonml

    markdown.toHTML(text, 'Tent', { footnotes: mentions, preprocessors: [externalLinkPreprocessor] })

