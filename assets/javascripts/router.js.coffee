# All routers should extend TentStatus.Router
# Any abstractions should go in here
class TentStatus.Router extends Backbone.Router
  keyForAction: (actionName) =>
    "#{@routerKey}:#{actionName}"

  setCurrentAction: (actionName, actionFn) =>
    if TentStatus.freezeRouter
      TentStatus.on 'router:unfreeze', (shouldPlay) => @setCurrentAction(actionName, actionFn) if shouldPlay

    key = @keyForAction(actionName)

    @_dataFetches ||= {}
    @_dataFetches[actionName] = 0
    
    @view?.empty()

    @currentActionName = actionName

    window.scrollTo window.scrollX, 0

    TentStatus.setPageTitle? key
    TentStatus.setCurrentRoute? @, actionName

    actionFn()

  isCurrentAction: (actionName) =>
    return true # currentRoute not currently setup, TODO set this up
    TentStatus.currentRoute?.key == @keyForAction(actionName)

  fetchData: (dataKey, dataFn) =>
    actionName = @currentActionName

    if dataFn.length == 0
      @_fetchData(dataKey, dataFn(), actionName)
    else
      dataFn (res) => @_fetchData(dataKey, res, actionName)

  _fetchData: (dataKey, res, actionName) =>
    loaded = =>
      @view?.set dataKey, res[dataKey]

      # yield for other fetchData calls to start
      setTimeout (=> @fetchSuccess actionName), 0

    if res.loaded is true
      @fetchStart actionName
      loaded()
    else
      res[dataKey].on 'fetch:start', (=> @fetchStart actionName)
      res[dataKey].on 'fetch:success', loaded
      if res[dataKey].isPaginator is true
        # TentStatus.Paginator triggers 'fetch:start' and 'fetch:success' events
        res[dataKey].fetch()
      else
        res[dataKey].trigger 'fetch:start'
        res[dataKey].fetch success: (=> res[dataKey].trigger 'fetch:success')

  fetchStart: (actionName) =>
    return unless @isCurrentAction(actionName)
    @_dataFetches[actionName]++
    TentStatus.Views.loading?.show()

  fetchSuccess: (actionName) =>
    return unless @isCurrentAction(actionName)
    @_dataFetches[actionName]-- unless @_dataFetches[actionName] == 0
    if @_dataFetches[actionName] == 0
      @view?.once 'ready', =>
        TentStatus.Views.loading?.hide()
      @view?.render()

