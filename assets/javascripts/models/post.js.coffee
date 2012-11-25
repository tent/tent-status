TentStatus.Models.Post = class PostModel extends TentStatus.Model
  @model_name: 'post'

  isRepost: =>
    !!(@get('type') || '').match(/repost/)

  postMentions: =>
    @post_mentions ?= _.select @get('mentions') || [], (m) => m.entity && m.post

