MEDIA_TYPE = 'application/vnd.tent.v0+json'

Marbles.HTTP.Middleware ||= {}
Marbles.HTTP.Middleware.TentJSONHeader = {
  process: (request, body) ->
    request.setHeader('Accept', MEDIA_TYPE)
    if body && ["POST", "PUT", "PATCH"].indexOf(request.method.toUpperCase()) != -1
      request.setHeader('Content-Type', MEDIA_TYPE)
}
