#= require 'jquery'

@HTTP = {
  get: (path, callback) ->
    $.get path, callback

  post: (path, data, callback) ->
    $.ajax
      type: 'POST'
      url: path
      data: JSON.stringify(data)
      dataType: 'json'
      contentType: 'application/json'
      success: callback
      beforeSend: (xhr) ->
        token = TentStatus.csrf_token
        xhr.setRequestHeader('X-CSRF-Token', token) if token
}
