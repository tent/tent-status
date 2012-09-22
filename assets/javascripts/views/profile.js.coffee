class TentStatus.Views.Profile extends TentStatus.Views.Posts
  templateName: 'profile'
  partialNames: ['_post', '_post_inner', '_reply_form']

  dependentRenderAttributes: ['currentProfile']

  initialize: ->
    super

    @on 'change:profile', @render

    new HTTP 'GET', "#{TentStatus.config.current_tent_api_root}/profile", null, (profile, xhr) =>
      return unless xhr.status == 200
      @set 'profile', new TentStatus.Models.Profile profile

  replyToPost: (post) =>
    return unless post.get('mentions')?.length
    for mention in post.get('mentions')
      if mention.entity and mention.post
        mention.url = "#{TentStatus.url_root}#{encodeURIComponent(mention.entity)}/#{mention.post}"
        return mention
    null

  context: =>
    return {} unless @profile
    window.profile = @profile
    profile:
      name: @profile.name()
      bio: @profile.bio()
      avatar: @profile.avatar()
      hasName: @profile.hasName()
      entity: @profile.entity()
      encoded:
        entity: encodeURIComponent(@profile.entity())
      formatted:
        entity: TentStatus.Helpers.formatUrl @profile.entity()

