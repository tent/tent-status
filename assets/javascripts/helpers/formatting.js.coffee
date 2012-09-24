_.extend TentStatus.Helpers,
  formatTime: (time_or_int) ->
    now = moment()
    time = moment.unix(time_or_int)

    formatted_time = if time.format('YYYY-MM-DD') == now.format('YYYY-MM-DD')
      time.format('HH:mm') # time only
    else
      time.format('DD/MM/YY') # date and time

    "#{formatted_time}"

  rawTime: (time_or_int) ->
    moment.unix(time_or_int).format()

  formatUrl: (url='') ->
    url.replace(/^\w+:\/\/([^\/]+).*?$/, '$1')

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

  autoLinkText: (text) ->
    return unless text

    text = TentStatus.Helpers.htmlEscapeText(text)

    for i in TentStatus.Helpers.extractUrlsWithIndices(text)
      text = TentStatus.Helpers.replaceIndexRange(i.indices[0], i.indices[1], text, "<a href='#{TentStatus.Helpers.ensureUrlHasScheme(i.url)}'>#{text.substring(i.indices[0], i.indices[1])}</a>")

    text
