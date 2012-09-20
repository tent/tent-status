class TentStatus.Models.Group extends Backbone.Model
  model: 'group'
  url: => "#{TentStatus.api_root}/groups#{ if @id then "/#{@id}" else ''}"

