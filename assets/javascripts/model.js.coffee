TentStatus.Model = class Model extends Marbles.Model
  @fetchCount: (params, options = {}) ->
    return unless params.entity && @resource_path
    unless options.client
      return HTTP.TentClient.find entity: (params.entity), (client) =>
        @fetchCount(params, _.extend(options, {client: client}))

    options.client.head @resource_path, params.fetch_params, (res, xhr) =>
      unless xhr.status == 200
        options.error?(res, xhr)
        return

      count = parseInt(xhr.getResponseHeader('Count'))
      options.success?(count, xhr)
