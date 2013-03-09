TentStatus.PaginationLinkHeader = class PaginationLinkHeader extends TentStatus.Object
  constructor: (link_header='') ->
    @pagination_params = {}
    parts = link_header.split(/,\s*/)
    for part in parts
      continue unless part.match(/<([^>]+)>;\s*rel=['"]([^'"]+)['"]/)
      continue unless RegExp.$2 in ['next', 'prev']
      path = RegExp.$1
      params = Marbles.History::deserializeParams(path.split('?')[1])
      @pagination_params[RegExp.$2] = params
