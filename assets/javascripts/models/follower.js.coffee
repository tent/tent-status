class StatusPro.Models.follower extends Backbone.Model
  model: 'follower'
  url: => "#{StatusPro.api_root}/followers#{ if @id then "/#{@id}" else ''}"

