Marbles.Views.MentionsAutoCompleteTextarea = class MentionsAutoCompleteTextareaView extends Marbles.View
  @view_name: 'mentions_autocomplete_textarea'

  constructor: (options = {}) ->
    super

    @initInlineMentionsManager()

  initInlineMentionsManager: =>
    @inline_mentions_manager = new TentStatus.InlineMentionsManager(el: @el)

  setCursorPosition: =>
    @current_selection = new Marbles.DOM.InputSelection(@el)

  focus: =>
    if @current_selection
      selection = @current_selection
      selection.setSelectionRange(selection.start, selection.start)
    else
      selection = new Marbles.DOM.InputSelection(@el)
      end = @el.value.length
      selection.setSelectionRange(end, end)

