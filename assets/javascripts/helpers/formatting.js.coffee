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

  formatUrlWithPath: (url = '') ->
    url.replace(/^\w+:\/\/(.*)$/, '$1')

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

    urls = TentStatus.Helpers.extractUrlsWithIndices(text)
    mentions = TentStatus.Helpers.extractMentionsWithIndices(text, {exclude_urls: true, uniq: false})

    return text unless urls.length or mentions.length

    urls_and_mentions = []
    uniq_indices = {}
    for item in urls.concat(mentions)
      for start_index, i in item.indices
        continue if i % 2
        end_index = item.indices[i+1]

        original = text.substring(start_index, end_index)
        urls_and_mentions.push {
          url: item.url
          html: "<a href='#{TentStatus.Helpers.ensureUrlHasScheme(item.url)}'>#{TentStatus.Helpers.formatUrlWithPath(original)}</a>"
          start_index: start_index
          end_index: end_index
        } unless uniq_indices[start_index]
        uniq_indices[start_index] = true

    urls_and_mentions = _.sortBy(urls_and_mentions, (i) -> i.start_index)

    offset = 0
    for i in urls_and_mentions
      start_index = i.start_index + offset
      end_index = i.end_index + offset
      original_text = text.substring(start_index, end_index)
      replace_text = i.html
      delta = replace_text.length - original_text.length
      offset += delta
      text = TentStatus.Helpers.replaceIndexRange(start_index, end_index, text, replace_text)

    text
