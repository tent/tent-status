TentStatus.Views.PostProfileName = class PostProfileNameView extends TentStatus.Views.ProfileView
  @template_name: '_post_profile_name'

  constructor: ->
    super

    @post_cid = DOM.attr(@el, 'data-post_cid')
    @fetch()
