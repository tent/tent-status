class StatusPro.Models.Follower extends Backbone.Model
  model: 'follower'
  url: => "#{StatusPro.api_root}/followers#{ if @id then "/#{@id}" else ''}"

