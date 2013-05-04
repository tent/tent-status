Marbles.Views.MentionsAutoCompleteTextareaContainer = class MentionsAutoCompleteTextareaContainerView extends Marbles.View
  @template_name: 'mentions_autocomplete_textarea_container'
  @view_name: 'mentions_autocomplete_textarea_container'

  constructor: (options = {}) ->
    super

    @on 'init:MentionsAutoCompleteTextarea', (view) =>
      @mentions_autocomplete_textarea_view_cid = view.cid

    @render()

  optionsInclude: (option) =>
    Marbles.View.find(@mentions_autocomplete_textarea_view_cid)?.optionsInclude(option)

  addOption: (option) =>
    Marbles.View.find(@mentions_autocomplete_textarea_view_cid)?.addOption(option)

