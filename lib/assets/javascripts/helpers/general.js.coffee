_.extend TentStatus.Helpers,
  # Taken from http://mths.be/punycode
  decodeUCS: (string) ->
    chars = []
    counter = 0
    length = string.length

    while counter < length
      value = string.charCodeAt(counter++)
      if value >= 0xD800 && value <= 0xDBFF && counter < length
        # high surrogate, and there is a next character
        extra = string.charCodeAt(counter++)
        if (extra & 0xFC00) == 0xDC00 # low surrogate
          chars.push(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000)
        else
          # unmatched surrogate; only append this code unit, in case the next
          # code unit is the high surrogate of a surrogate pair
          chars.push(value)
          counter--
      else
        chars.push(value)

    chars

  numChars: (string) ->
    return 0 unless string
    @decodeUCS(string).length

  replaceIndexRange: (start_index, end_index, string, replacement) ->
    string.substr(0, start_index) + replacement + string.substr(end_index, string.length-1)

  substringIndices: (string, substring, invalid_after) ->
    return [] unless string and substring

    _indices = []
    _length = substring.length
    _offset = 0
    while string.length
      i = string.substr(_offset, string.length).indexOf(substring)
      break if i == -1
      _start_index = i + _offset
      _end_index = _start_index + _length
      break if string.substr(_end_index, 1).match(invalid_after) if invalid_after
      _offset += i + _length
      _indices.push _start_index, _end_index

    _indices

  escapeRegExChars: (string) ->
    string ?= ""
    string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
