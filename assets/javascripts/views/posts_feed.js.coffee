TentStatus.Views.PostsFeed = class PostsFeedView extends TentStatus.View
  @template_name: 'posts_feed'
  @partial_names: ['_reply_form', '_post', '_post_inner', '_post_inner_actions']

  constructor: (options = {}) ->
    super

    @on 'ready', @initPostViews

    @posts_collection = new TentStatus.Collections.Posts
    @fetch()

  fetch: (params = {}, options = {}) =>
    TentStatus.trigger 'loading:start'
    @posts_collection.fetch params, _.extend(options,
      success: (posts) =>
        TentStatus.trigger 'loading:stop'
        @posts_collection.since_id = _.last(posts)?.id
        @posts_collection.since_id_entity = _.last(posts)?.entity

        if options.append
          @appendRender()
        else
          @render()

      error: (res, xhr) =>
        TentStatus.trigger 'loading:stop'
    )

  nextPage: =>
    @fetch {
      since_id: @posts_collection.since_id
      since_id_entity: @posts_collection.since_id_entity
    }, {
      append: true
    }

  initPostViews: =>

  context: =>
    posts: _.map(@posts_collection.models(), (post) =>
      TentStatus.Views.Post::context(post)
    )

  appendRender: =>

