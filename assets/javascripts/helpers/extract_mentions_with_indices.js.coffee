_.extend TentStatus.Helpers,
  extractMentionsWithIndices: (text, options = {}) ->
    _mentions = []
    _entities = {}

    _from_urls = []
    unless options.exclude_urls == true
      for i in TentStatus.Helpers.extractUrlsWithIndices(text)
        entity = i.url
        _is_carrot_mention = text.substr(i.indices[0]-1, 1) == '^'
        _is_tent_subdomain = entity.match(new RegExp("\\w+\.#{TentStatus.Helpers.escapeRegExChars(TentStatus.config.tent_host_domain)}/?\\$"))
        continue unless _is_carrot_mention or _is_tent_subdomain

        original_text = entity

        unless entity.match(/^https?:\/\//)
          scheme = 'https://'
          entity = scheme + entity

        entity = entity.replace(/\/$/, '')
        url = if typeof options.process_entity_fn == 'function' then options.process_entity_fn(entity) else entity
        _from_urls.push {
          entity: entity
          url: url
          text: original_text
          indices: i.indices
        } unless (_entities[entity] and options.uniq != false)
        _entities[entity] = true

    _from_mentions = []

    _regex = new RegExp("([\\^]([a-z0-9]{2,}))(?!:\/\/)(?=[\\W]|$)", "i")
    _offset = 0
    _text = text
    while (_text = text.substr(_offset, text.length)) && _text.length && _regex.exec(_text)
      matched = RegExp.$1
      entity = RegExp.$2
      continue unless entity

      _offset += _text.indexOf(matched) + matched.length
      original_text = entity
      _length = original_text.length
      _indices = TentStatus.Helpers.substringIndices(text, matched, /[a-z0-9]/i)
      if entity.match(/^[^.]+\.\w+/i)
        entity = "https://#{entity}"
      else
        if options.entity_whitelist
          found = false
          for url in options.entity_whitelist
            if url.match(new RegExp "^[a-z]+:\/\/#{TentStatus.Helpers.escapeRegExChars entity}\.", "i")
              entity = url
              found = true
              break
          continue unless found
        else if TentStatus.config.tent_host_domain
          entity = "https://#{entity}.#{TentStatus.config.tent_host_domain}"

        should_skip = false

        indexRangesForIndices = (indices) ->
          _ranges = []
          for start_index, index in indices
            continue if index % 2
            end_index = indices[index+1]
            _ranges.push [start_index..end_index]
          _ranges

        _index_ranges = indexRangesForIndices(_indices)

        doIndexRangesOverlap = (ranges_a, ranges_b) ->
          for r_a in ranges_a
            for r_b in ranges_b
              return true if _.intersection(r_a, r_b).length
          false

        for i in _from_urls
          i_index_ranges = indexRangesForIndices(i.indices)
          if doIndexRangesOverlap(_index_ranges, i_index_ranges)
            should_skip = true
            break

        continue if should_skip

        url = if typeof options.process_entity_fn == 'function' then options.process_entity_fn(entity.toLowerCase()) else entity.toLowerCase()
        _from_mentions.push {
          entity: entity.toLowerCase()
          text: original_text
          url: url
          indices: _indices
        } unless (_entities[entity] and options.uniq != false)
        _entities[entity] = true

    _mentions = _from_urls.concat(_from_mentions)
    _mentions
