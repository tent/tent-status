class StatusPro.Models.Following extends Backbone.Model
  model: 'following'
  url: => "#{StatusPro.api_root}/followings#{ if @id then "/#{@id}" else ''}"

