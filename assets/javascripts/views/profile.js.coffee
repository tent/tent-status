class TentStatus.Views.Profile extends TentStatus.Views.Posts
  templateName: 'profile'
  partialNames: ['_post', '_post_inner', '_reply_form']

  initialize: ->
    @dependentRenderAttributes.push 'currentProfile'
    super

  replyToPost: (post) =>
    return unless post.get('mentions')?.length
    for mention in post.get('mentions')
      if mention.entity and mention.post
        mention.url = "#{TentStatus.url_root}#{encodeURIComponent(mention.entity)}/#{mention.post}"
        return mention
    null

  context: =>
    _.extend super,
      profile: _.extend( @currentProfile.toJSON(),
        name: @currentProfile.name()
        bio: @currentProfile.bio()
        nameIsEntity: @currentProfile.name() == TentStatus.Helpers.formatUrl(@currentProfile.entity())
        avatar: @currentProfile.avatar()
        entity: @currentProfile.entity()
        encoded:
          entity: encodeURIComponent(@currentProfile.entity())
        formatted:
          entity: TentStatus.Helpers.formatUrl @currentProfile.entity()
      )
