_.extend TentStatus.Helpers,
  extractHashtagsWithIndices: (text, options = {}) ->
    hashtags = []
    _regex = /(#(?:<\w+>)?(\w+)(?:<\/\w+>)?)/
    _offset = 0
    _text = text

    while (_text = text.substr(_offset, text.length)) && _text.length && _regex.exec(_text)
      original = RegExp.$1
      tag = RegExp.$2
      index = _text.indexOf(original) + _offset
      _offset = index + original.length

      continue if text.substr(index-1, 1) == '&'

      hashtags.push _.extend({
        tag: tag
        text: "##{tag}"
        original: original
        start_index: index
        end_index: index + original.length
      }, options.process?(tag) || {})

    hashtags
