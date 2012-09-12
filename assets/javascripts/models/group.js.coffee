class StatusPro.Models.Group extends Backbone.Model
  model: 'group'
  url: => "#{StatusPro.api_root}/groups#{ if @id then "/#{@id}" else ''}"

