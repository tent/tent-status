TentStatus.Views.PostReplyForm = class PostReplyFormView extends TentStatus.Views.NewPostForm
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'

  is_reply_form: true

  constructor: ->
    super

  toggle: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    DOM.hide(@el)

  show: =>
    @visible = true
    setImmediate =>
      @constructor.instances.all[@_child_views.MentionsAutoCompleteTextarea?[0]]?.textarea_view?.focus()
    if @ready
      DOM.show(@el)
    else
      @render()

  post: =>
    TentStatus.Models.Post.instances.all[@parent_view.post_cid]

  context: =>
    post = @post()
    reply_to_entities = (_.map post.postMentions(), (m) => m.entity)
    reply_to_entities.push(post.entity) unless TentStatus.Helpers.isCurrentUserEntity(post.entity)
    _.extend {}, super,
      max_chars: TentStatus.config.MAX_LENGTH
      id: post.id
      entity: post.entity
      formatted:
        reply_to_entities: reply_to_entities

