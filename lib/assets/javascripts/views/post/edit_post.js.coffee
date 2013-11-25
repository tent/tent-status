bindFn = (fn, me) ->
  return -> fn.apply(me, arguments)

Marbles.Views.EditPost = class EditPostView extends Marbles.View
  @template_name: 'edit_post'
  @view_name: 'edit_post'

  render_method: 'replace'

  constructor: ->
    # inherit most NewPostForm methods
    _blacklist = ['constructor', 'initialRender', 'post', 'submit', 'buildPostAttributes']
    for k, fn of Marbles.Views.NewPostForm::
      continue unless Marbles.Views.NewPostForm::.hasOwnProperty(k)
      continue if _blacklist.indexOf(k) != -1
      @[k] = bindFn(fn, @)

    super

  initialize: (options = {}) ->
    @elements ?= {}
    @text = {}

    @mentions = []

    post = options.parent_view.post()
    @post_cid = post.cid

    @entity = post.get('entity')

    profile = TentStatus.Models.MetaProfile.find(entity: @entity, fetch: false)
    unless profile
      profile = new TentStatus.Models.MetaProfile(entity: @entity)
      profile.fetch(null, success: @profileFetchSuccess)
    @profile_cid = profile.cid

    @on 'ready', @bindCancel
    @on 'ready', @initPermissions
    @on 'ready', @initPostMarkdown
    @on 'ready', @focusTextarea
    @on 'ready', @init
    @on 'ready', =>
      @permissionsFieldsView().subscribeToMentions()
      @textareaMentionsView().inline_mentions_manager.updateMentions()

  bindCancel: =>
    @elements.cancel_el = @el.querySelector('[data-action=cancel]')

    Marbles.DOM.on @elements.cancel_el, 'click', @renderPost

  permissionsFieldsView: =>
    @childViews('PermissionsFields')[0]

  initPermissions: =>
    entities = @post().get('permissions.entities') || []
    permissions_view = @permissionsFieldsView()

    for entity in entities
      permissions_view.addOption(
        text: TentStatus.Helpers.minimalEntity(entity)
        value: entity
      )

  initPostMarkdown: =>
    markdown = TentStatus.Helpers.expandTentMarkdown(@post().get('content.text'), @post().get('mentions'))
    textarea_view = @textareaMentionsView()
    textarea_view.el.value = markdown

  renderPost: =>
    @parentView().render()

  buildPostAttributes: =>
    attrs = Marbles.DOM.serializeForm(@elements.form)
    @buildPostMentionsAttributes(attrs)
    @buildPostPermissionsAttributes(attrs)
    attrs = _.extend attrs, {
      type: @post().get('type').toString()
    }
    attrs.content = { text: @textareaMentionsView().inline_mentions_manager.processedMarkdown() }
    delete attrs.text
    attrs

  submit: (data) =>
    @disableWith(@text.disable_with)
    data ?= @buildPostAttributes()

    @post().update(data,
      failure: (res, xhr) =>
        @enable()
        @showErrors([{ text: "Error: #{JSON.parse(xhr.responseText)?.error}" }])

      success: @renderPost
    )

  post: =>
    Marbles.Model.find(cid: @post_cid)

  render: =>
    super

    # the element is replaced on render
    @parentView().el = @el

