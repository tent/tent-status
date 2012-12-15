TentStatus.Views.EditPostMentionsAutoCompleteTextarea = class EditPostMentionsAutoCompleteTextareaView extends TentStatus.Views.MentionsAutoCompleteTextarea
  @template_name: 'edit_post_mentions_autocomplete_textarea'
  @view_name: 'edit_post_mentions_autocomplete_textarea'

  context: =>
    @parent_view.context()
