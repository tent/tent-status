HTTP.Middleware ||= {}
class HTTP.Middleware.SerializeJSON
  process: (http, body) =>
    data = if http.data then JSON.stringify(http.data) else null
    data = null if data == "{}" or data == "[]"
    http.data = data

  processResponse: (http, xhr) =>
    if xhr.response && ((xhr.status in [200...400]) || (xhr.response?[0] == '{'))
      data = JSON.parse(xhr.response)
    else
      data = null
    http.response_data = data
