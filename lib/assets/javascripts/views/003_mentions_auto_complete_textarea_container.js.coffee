Marbles.Views.MentionsAutoCompleteTextareaContainer = class MentionsAutoCompleteTextareaContainerView extends Marbles.View
  @template_name: 'mentions_autocomplete_textarea_container'
  @view_name: 'mentions_autocomplete_textarea_container'

  constructor: (options = {}) ->
    super

    @on 'init:MentionsAutoCompleteTextarea', (view) =>
      @mentions_autocomplete_textarea_view_cid = view.cid

    @on 'ready', @initMarkdownPreview

    @render()

  initMarkdownPreview: =>
    @elements ?= {}

    @_mode = 'edit'

    @elements.toggles = {
      edit: Marbles.DOM.querySelector('[data-action=edit-markdown]', @el)
      preview: Marbles.DOM.querySelector('[data-action=preview-markdown]', @el)
    }

    @elements.preview = Marbles.DOM.querySelector('.markdown-preview', @el)
    @elements.textarea = Marbles.DOM.querySelector('textarea', @el)

    Marbles.DOM.on @elements.toggles.edit, 'click', (e) =>
      return if @_mode is 'edit'
      @_mode = 'edit'
      Marbles.DOM.hide(@elements.preview)
      Marbles.DOM.show(@elements.textarea)
      @textareaView().focus()

    Marbles.DOM.on @elements.toggles.preview, 'click', (e) =>
      return if @_mode is 'preview'
      @_mode = 'preview'
      Marbles.DOM.removeChildren(@elements.preview)
      mentions = _.map @textareaView().inline_mentions_manager.entities, (e) => { entity: e }
      html = TentStatus.Helpers.formatTentMarkdown(@textareaView().inline_mentions_manager.processedMarkdown(), mentions)
      Marbles.DOM.appendHTML(@elements.preview, html)
      Marbles.DOM.hide(@elements.textarea)
      Marbles.DOM.show(@elements.preview)

  textareaView: =>
    Marbles.View.find(@mentions_autocomplete_textarea_view_cid)

  optionsInclude: (option) =>
    @textareaView()?.optionsInclude(option)

  addOption: (option) =>
    @textareaView()?.addOption(option)

