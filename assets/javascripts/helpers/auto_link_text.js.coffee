_.extend TentStatus.Helpers,
  flattenUrlsWithIndices: (items) ->
    _flattened = []
    for item in items
      for start_index, i in item.indices
        continue if i % 2
        end_index = item.indices[i+1]

        _item = _.clone(item)
        delete _item.indices
        _item.start_index = start_index
        _item.end_index = end_index
        _flattened.push _item
    _flattened

  autoLinkText: (text, options = {}) ->
    return unless text

    text = TentStatus.Helpers.htmlEscapeText(text)

    urls = TentStatus.Helpers.flattenUrlsWithIndices(TentStatus.Helpers.extractUrlsWithIndices text)
    mentions = TentStatus.Helpers.flattenUrlsWithIndices(
      TentStatus.Helpers.extractMentionsWithIndices(text, _.extend({uniq: false, process_entity_fn: TentStatus.Helpers.entityProfileUrl }, options))
    )
    hashtags = TentStatus.Helpers.extractHashtagsWithIndices text, process: (tag) =>
      query_string = "?q=" + encodeURIComponent("#" + tag)
      url = if TentStatus.config.search_api_root
        "/search#{query_string}"
      else
        "https://skate.io/search#{query_string}"
      { url: url }

    return text unless urls.length or mentions.length or hashtags.length

    updateIndicesWithOffset = (items, start_index, delta) ->
      items = for i in items
        if i.start_index >= start_index
          i.start_index += delta
          i.end_index += delta
        i
      items

    removeOverlappingItems = (items, start_index, end_index) ->
      _new_items = []
      for i in items
        _indices = [start_index..end_index]
        _i_indices = [i.start_index..i.end_index]
        unless _.intersection(_indices, _i_indices).length
          _new_items.push i
      _new_items

    urls_mentions_and_hashtags = mentions.concat(urls).concat(hashtags)
    while urls_mentions_and_hashtags.length
      item = urls_mentions_and_hashtags.shift()
      original = text.substring(item.start_index, item.end_index)
      link_attributes = []

      [item.url, trailing_text] = TentStatus.Helpers.extractTrailingHtmlEntitiesFromText(item.url)
      [original, original_trailing_text] = TentStatus.Helpers.extractTrailingHtmlEntitiesFromText(original)

      if TentStatus.Helpers.isURLExternal(item.url)
        link_attributes.push "data-view='ExternalLink'"

      html = "<a href='#{TentStatus.Helpers.ensureUrlHasScheme(item.url)}' #{link_attributes.join(' ')}>" +
             TentStatus.Helpers.truncate(TentStatus.Helpers.formatUrlWithPath(original), TentStatus.config.URL_TRIM_LENGTH) + "</a>#{trailing_text}"
      delta = html.length - original.length
      updateIndicesWithOffset(urls_mentions_and_hashtags, item.start_index, delta)
      urls_mentions_and_hashtags = removeOverlappingItems(urls_mentions_and_hashtags, item.start_index, item.end_index + delta)

      text = TentStatus.Helpers.replaceIndexRange(item.start_index, item.end_index, text, html)

    text

