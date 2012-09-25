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

    offset = 0
    for i in TentStatus.Helpers.extractUrlsWithIndices(text)
      start_index = i.indices[0] + offset
      end_index = i.indices[1] + offset
      original_text = text.substring(start_index, end_index)
      replace_text = "<a href='#{TentStatus.Helpers.ensureUrlHasScheme(i.url)}'>#{original_text}</a>"
      delta = replace_text.length - original_text.length
      offset += delta
      text = TentStatus.Helpers.replaceIndexRange(start_index, end_index, text, replace_text)

    text
