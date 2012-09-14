class StatusApp.Models.Group extends Backbone.Model
  model: 'group'
  url: => "#{StatusApp.api_root}/groups#{ if @id then "/#{@id}" else ''}"

