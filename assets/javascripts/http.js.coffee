#= require 'jquery'

@HTTP = {
  get: (path, callback) ->
    $.get path, callback
}
