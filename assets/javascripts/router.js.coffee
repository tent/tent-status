# All routers should extend StatusPro.Router
# Any abstractions should go in here
class StatusPro.Router extends Backbone.Router
  keyForAction: (actionName) =>
    "#{@routerKey}:#{actionName}"

  setCurrentAction: (actionName, actionFn) =>
    if StatusPro.freezeRouter
      StatusPro.on 'router:unfreeze', (shouldPlay) => @setCurrentAction(actionName, actionFn) if shouldPlay

    key = @keyForAction(actionName)

    @_dataFetches ||= {}
    @_dataFetches[actionName] = 0
    
    @view?.empty()

    @currentActionName = actionName

    window.scrollTo window.scrollX, 0

    StatusPro.setPageTitle? key
    StatusPro.setCurrentRoute? @, actionName

    actionFn()

  isCurrentAction: (actionName) =>
    return true # currentRoute not currently setup, TODO set this up
    StatusPro.currentRoute?.key == @keyForAction(actionName)

  fetchData: (dataKey, dataFn) =>
    actionName = @currentActionName

    loaded = =>
      @view?.set dataKey, res[dataKey]

      # yield for other fetchData calls to start
      setTimeout (=> @fetchSuccess actionName), 0

    res = dataFn()
    if res.loaded is true
      @fetchStart actionName
      loaded()
    else
      res[dataKey].on 'fetch:start', (=> @fetchStart actionName)
      res[dataKey].on 'fetch:success', loaded
      if res[dataKey].isPaginator is true
        # StatusPro.Paginator triggers 'fetch:start' and 'fetch:success' events
        res[dataKey].fetch()
      else
        res[dataKey].trigger 'fetch:start'
        res[dataKey].fetch success: (=> res[dataKey].trigger 'fetch:success')

  fetchStart: (actionName) =>
    return unless @isCurrentAction(actionName)
    @_dataFetches[actionName]++
    StatusPro.Views.loading?.show()

  fetchSuccess: (actionName) =>
    return unless @isCurrentAction(actionName)
    @_dataFetches[actionName]-- unless @_dataFetches[actionName] == 0
    if @_dataFetches[actionName] == 0
      @view?.once 'ready', =>
        StatusPro.Views.loading?.hide()
      @view?.render()

