String::score = (abbreviation) ->
  string = @

  return 1 if string == abbreviation

  index = string.indexOf(abbreviation)

  # only allow substrings to match
  return 0 if index == -1

  return 1 if index == 0

  abbreviation.length / string.length

