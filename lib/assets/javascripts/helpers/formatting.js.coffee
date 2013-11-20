_.extend TentStatus.Helpers,
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

  minimalEntity: (entity) ->
    @formatUrlWithPath(entity)

  formatUrlWithPath: (url = '') ->
    url.replace(/^\w+:\/\/(.*)$/, '$1')

  capitalize: (string) ->
    string.substr(0, 1).toUpperCase() + string.substr(1, string.length)

  pluralize: (word, count, plural) ->
    if count is 1 || count is -1
      word
    else
      plural

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

  extractTrailingHtmlEntitiesFromText: (text) ->
    trailing_text = ""
    for char, entities of TentStatus.Helpers.HTML_ENTITIES
      regex = new RegExp("(#{TentStatus.Helpers.escapeRegExChars(entities)}?)$")
      if regex.test(text)
        trailing_text = text.match(regex)[1] + trailing_text
        text = text.replace(regex, "")
    [text, trailing_text]

  truncate: (text, length, elipses='...', options = {}) ->
    return text unless text
    if text.length > length
      _truncated = text.substr(0, length-elipses.length)
      _truncated += elipses
    else
      _truncated = text
    _truncated

  formatTentMarkdown: (text = '', mentions = []) ->
    inline_mention_urls = _.map mentions, (m) => TentStatus.Helpers.entityProfileUrl(m.entity)

    preprocessors = []

    parsePara = (para, callback) ->
      new_para = for item in para
        if _.isArray(item) && item[0] in ['para', 'strong', 'em', 'del']
          parsePara(item, callback)
        else if typeof item is 'string'
          callback(item)
        else
          item
      new_para

    externalLinkPreprocessor = (jsonml) ->
      return jsonml unless jsonml[0] is 'link'
      return jsonml unless TentStatus.Helpers.isURLExternal(jsonml[1]?.href)
      jsonml[1].href = TentStatus.Helpers.ensureUrlHasScheme(jsonml[1].href)
      jsonml[1]['data-view'] = 'ExternalLink'
      jsonml

    preprocessors.push(externalLinkPreprocessor)

    # Disable hashtag autolinking when search isn't enabled
    unless TentStatus.config.services.search_api_root
      disableHashtagAutolinking = (jsonml) ->
        return jsonml unless jsonml[0] is 'link'
        return jsonml unless jsonml[1]?.rel is 'hashtag'

        ['span', jsonml[2]]

      preprocessors.push(disableHashtagAutolinking)

    markdown.toHTML(text, 'Tent', {
      footnotes: inline_mention_urls
      hashtagURITemplate: @fullPath('/search') + '?q=%23{hashtag}'
      preprocessors: preprocessors
    })

  expandTentMarkdown: (text, mentions = []) ->
    # Replace mention indices with entity URI
    text.replace(/(\^\[[^\]]+\])\((\d+)\)/, (match, m1, m2) ->
      m1 + "(" + (mentions[m2]?.entity || '') + ")"
    )

