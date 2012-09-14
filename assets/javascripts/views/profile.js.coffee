class StatusApp.Views.Profile extends StatusApp.Views.Posts
  templateName: 'profile'
  partialNames: ['_post', '_reply_form']

  initialize: ->
    @dependentRenderAttributes.push 'currentProfile'
    super

  replyToPost: (post) =>
    return unless post.get('mentions')?.length
    for mention in post.get('mentions')
      if mention.entity and mention.post
        mention.url = "#{StatusApp.url_root}#{encodeURIComponent(mention.entity)}/#{mention.post}"
        return mention
    null

  context: =>
    _.extend super,
      profile: _.extend( @currentProfile.toJSON(),
        name: @currentProfile.name()
        avatar: @currentProfile.avatar()
        entity: @currentProfile.entity()
        encoded:
          entity: encodeURIComponent(@currentProfile.entity())
      )
