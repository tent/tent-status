Marbles.Views.MentionsAutoCompleteTextarea = class MentionsAutoCompleteTextareaView extends Marbles.View
  @view_name: 'mentions_autocomplete_textarea'

  constructor: (options = {}) ->
    super

    @initInlineMentionsManager()

  initInlineMentionsManager: =>
    @inline_mentions_manager = new TentStatus.InlineMentionsManager(el: @el)

