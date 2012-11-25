HTTP.Middleware ||= {}
class HTTP.Middleware.SerializeJSON
  process: (http, body) =>
    data = if http.data then JSON.stringify(http.data) else null
    data = null if data == "{}" or data == "[]"
    http.data = data

  processResponse: (http, xhr) =>
    data = if xhr.status == 200 and xhr.response then JSON.parse(xhr.response) else null
    http.response_data = data
