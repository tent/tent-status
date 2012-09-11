class StatusPro.Models.Post extends Backbone.Model
  model: 'post'
  url: => "#{StatusPro.api_root}/posts#{ if @id then "/#{@id}" else ''}"

  validate: (attrs) =>
    errors = []

    if attrs.text and attrs.text.match /^[\s\r]*$/
      errors.push { text: 'Status must not be empty' }

    if attrs.text and attrs.text.length > 140
      errors.push { text: 'Status must be no more than 140 characters' }

    return errors if errors.length
    null
