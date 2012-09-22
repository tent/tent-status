(($) ->
  methodMap = {
    'create': 'POST',
    'update': 'PUT',
    'delete': 'DELETE',
    'read'  : 'GET'
  }
  
  getUrl = (object) ->
    return null if !(object && object.url)
    return if _.isFunction(object.url) then object.url() else object.url
  
  urlError = ->
    throw new Error("A 'url' property or function must be specified")

  Backbone.sync = (method, model, options) ->
    type = methodMap[method]

    # Default JSON-request options.
    params = _.extend({
      type:         type,
      dataType:     'json',
      beforeSend: ( xhr ) ->
        token = TentStatus.csrf_token
        xhr.setRequestHeader('X-CSRF-Token', token) if token

        model.trigger('sync:start')
    }, options)

    if !params.url
      params.url = getUrl(model) || urlError()

    usejQuery = true
    if params.url.match(/^http/)
      usejQuery = false

    # Ensure that we have the appropriate request data.
    data = null
    if !params.data && model && (method == 'create' || method == 'update')
      params.contentType = 'application/json'

      data = {}

      jsonMethod = if model.toServerJSON then 'toServerJSON' else 'toJSON'

      if model.paramRoot
        data[model.paramRoot] = model[jsonMethod]()
      else
        data = model[jsonMethod]()

      params.data = JSON.stringify(data)

    # Don't process data on a non-GET request.
    params.processData = false if (params.type != 'GET')

    # Trigger the sync end event
    complete = options.complete
    params.complete = (jqXHR, textStatus) ->
      model.trigger('sync:end')
      complete(jqXHR, textStatus) if complete
    
    # Make the request.
    if usejQuery
      $.ajax(params)
    else
      model.trigger('sync:start')
      new HTTP params.type, params.url, data, (data, xhr) =>
        model.trigger('sync:end')
        options.complete?(data, xhr.status, xhr)
        if xhr.status == 200
          options.success?(data, xhr.status, xhr)
        else
          options.error?(data, xhr.status, xhr)
  
)(window.jQuery || window.Zepto || window.ender)
