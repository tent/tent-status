Marbles.Views.SubscribersFeed = class SubscribersFeedView extends Marbles.Views.PostsFeed
  @template_name: 'relationships_feed'
  @partial_names: ['relationship']
  @view_name: 'subscribers_feed'
  @last_post_selector: "[data-view=SubscribersFeed] li.post:last-of-type"

  initialize: (options = {}) =>
    options.types = TentStatus.config.subscriber_feed_types
    options.entity = options.parent_view.entity
    options.headers = {
      'Cache-Control': 'proxy'
    }
    options.feed_queries = [
      { types: options.types, profiles: 'mentions', entities: options.entity }
    ]

    @ul_el = Marbles.DOM.querySelector('ul', @el)

    super(options)

  getEntity: =>
    @parentView()?.entity

  shouldAddPostToFeed: (post) =>
    true

  appendRender: (posts) =>
    fragment = document.createDocumentFragment()
    for post in posts
      Marbles.DOM.appendHTML(fragment, @renderSubscriberHTML(post))

    @bindViews(fragment)
    @ul_el.appendChild(fragment)

  prependRender: (posts) =>
    fragment = document.createDocumentFragment()
    for post in posts
      Marbles.DOM.appendHTML(fragment, @renderSubscriberHTML(post))

    @bindViews(fragment)
    Marbles.DOM.prependChild(@ul_el, fragment)

  context: (relationships = @postsCollection().models()) =>
    relationships: relationships

  renderSubscriberHTML: (post) =>
    @constructor.partials['relationship'].render({ relationship: post }, @constructor.partials)

