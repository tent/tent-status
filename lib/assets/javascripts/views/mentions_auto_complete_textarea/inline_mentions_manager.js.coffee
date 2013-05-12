KEYS = {
  BACKSPACE: 8
  TAB: 9
  CLEAR: 12
  RETURN: 13
  SHIFT: 16
  CONTROL: 17
  OPTION: 18 # Alt/Option
  ESCAPE: 27
  SPACE: 32
  PAGE_UP: 33
  PAGE_DOWN: 34
  END: 35
  HOME: 36
  LEFT: 37
  UP: 38
  RIGHT: 39
  DOWN: 40
  DELETE: 46 # not backspace, the other one
  COMMAND: 91
}

KEYS.NAVIGATION = [
  KEYS.LEFT, KEYS.UP, KEYS.RIGHT, KEYS.DOWN, KEYS.PAGE_UP, KEYS.PAGE_DOWN, KEYS.HOME, KEYS.END
]

KEYS.NO_CHAR = KEYS.NAVIGATION.concat([
  KEYS.TAB, KEYS.CLEAR, KEYS.SHIFT, KEYS.CONTROL, KEYS.OPTION, KEYS.ESCAPE, KEYS.COMMAND
])

class TentStatus.InlineMentionsManager extends Marbles.Object
  constructor: (options = {}) ->
    @elements = {
      textarea: options.el
    }

    @entities = []
    @entity_mapping = {}
    @mention_index_mapping = {}

    @edit_mode_enabled = false

    @bindInputEvents()

  _isCarret: (e) =>
    e.shiftKey && e.keyCode == 54

  _isCtrlT: (e) =>
    # transpose characters
    e.ctrlKey && e.keyCode == 84

  _isCtrlD: (e) =>
    # delete forward
    e.ctrlKey && e.keyCode == 68

  _isCtrlH: (e) =>
    # delete backward
    e.ctrlKey && e.keyCode == 72

  _isCtrlK: (e) =>
    # delete forward to end of line
    e.ctrlKey && e.keyCode == 75

  _isCtrlM: (e) =>
    # same as enter key, insert new line
    e.ctrlKey && e.keyCode == 77

  _isCtrlU: (e) =>
    # delete text between beginning of line and cursor
    e.ctrlKey && e.keyCode == 85

  _isCtrlW: (e) =>
    # delete previous word
    e.ctrlKey && e.keyCode == 87

  _isCtrlY: (e) =>
    # paste
    e.ctrlKey && e.keyCode == 89

  replaceIndexRange: (start_index, end_index, replacement_text) =>
    full_text = @elements.textarea.value
    @elements.textarea.value = TentStatus.Helpers.replaceIndexRange(start_index, end_index, full_text, replacement_text)
    new_end_index = start_index + replacement_text.length
    end_index_delta = new_end_index - end_index
    @updateMentionsOffsetFromIndex(end_index, end_index_delta)

    end_index_delta

  getCursorPosition: =>
    selection = new Marbles.DOM.InputSelection @elements.textarea
    selection.start

  enableEditMode: =>
    console.log('enableEditMode')
    @edit_mode_enabled = true

  disableEditMode: =>
    console.log('disableEditMode')
    @edit_mode_enabled = false
    @current_start_index = null

  createMention: (start_index, end_index, options = {}) =>
    entity = options.entity
    display_text = options.display_text
    input_text = options.input_text

    @entities.push(entity) if @entities.indexOf(entity) is -1
    entity_index = @entities.indexOf(entity)
    @entity_mapping[entity] ?= {
      index: entity_index
      inline_mentions: []
    }

    # replace text entered with markdown
    markdown = "[#{display_text}](#{entity_index})" # "^" is directly before start_index
    end_index_delta = @replaceIndexRange(start_index, end_index, markdown)
    end_index += end_index_delta

    # bring focus back to textarea
    selection = new Marbles.DOM.InputSelection @elements.textarea
    selection.setSelectionRange(end_index, end_index)

    inline_mention = new InlineMention(
      manager: @
      input_text: input_text
      indices: [start_index, end_index]
      text: display_text
      text_indices: [start_index + 1, start_index + 1 + display_text.length] # {start_index}[{display_text}
      entity: entity
      entity_index: entity_index
    )

    @entity_mapping[entity].inline_mentions.push(inline_mention)
    @mention_index_mapping[start_index] = inline_mention

  editMention: (mention, current_index, e) =>
    @current_mention = mention
    @current_start_index = mention.indices[0]

    if @_editing_display_text is true || ((current_index >= mention.text_indices[0] && current_index <= mention.text_indices[1]) && (e.keyCode != KEYS.BACKSPACE || current_index != mention.text_indices[0]))
      @_editing_display_text = true # ensure we always make it back here before keyup fires

      @once 'keyup', (e) =>
        @_editing_display_text = null

        input = @elements.textarea.value.slice(mention.indices[0], @elements.textarea.value.length)
        m = input.match(/^\[([^\]]{0,})\]/)

        unless m
          m = input.match(/\[([^\]]{0,})\]/)
          console.log('edit went bad, attempting to fix', JSON.stringify(input), m)
          mention.updateInputIndices(m.index) if m # correct indices

        unless m
          # something's wrong, untrack mention
          console.log('edit went bad', JSON.stringify(input), m)
          @untrackMention(mention)
          return

        new_display_text = m[1]
        length_delta = new_display_text.length - mention.text.length
        mention.text = new_display_text
        mention.text_indices[1] += length_delta
        mention.indices[1] += length_delta
    else
      # we're not editing the display text
      e.preventDefault() if e.keyCode is KEYS.BACKSPACE
      start_index = mention.indices[0]
      end_index = mention.indices[1]
      end_index_delta = @replaceIndexRange(start_index, end_index, mention.input_text)
      selection = new Marbles.DOM.InputSelection @elements.textarea
      end_index += end_index_delta
      selection.setSelectionRange(end_index, end_index)

      @untrackMention(mention)
      @enableEditMode()

  updateMentionEntityIndex: (mention, new_entity_index) =>
    mention.entity_index = new_entity_index

    start_index = mention.indices[0]
    end_index = mention.indices[1]

    selection = new Marbles.DOM.InputSelection @elements.textarea

    end_index_delta = @replaceIndexRange(start_index, end_index, mention.renderMarkdown())
    new_end_index = end_index + end_index_delta

    if selection.end >= end_index
      selection.end += end_index_delta

    selection.setSelectionRange(selection.start, selection.end)

  untrackIndices: (start, end) =>
    for pos, mention of @mention_index_mapping
      continue unless pos >= start && pos <= end
      @untrackMention(mention)

  untrackMention: (mention) =>
    delete @mention_index_mapping[mention.indices[0]]
    @entity_mapping[mention.entity].inline_mentions = _.without(@entity_mapping[mention.entity].inline_mentions, mention) if @entity_mapping[mention.entity]
    unless @entity_mapping[mention.entity]?.inline_mentions.length
      delete @entity_mapping[mention.entity]
      @entities = @entities.slice(0, mention.entity_index).concat(@entities.slice(mention.entity_index+1, @entities.length))

      for pos, _mention of @mention_index_mapping
        continue unless _mention.entity_index >= mention.entity_index
        @updateMentionEntityIndex(_mention, _mention.entity_index-1)

    console.log('untrackMention', mention)

  findMentionFromPosition: (index) =>
    inline_mention = null

    # look for mention for which index is in the bounds of
    for _pos, _mention of @mention_index_mapping
      if index >= _mention.indices[0] && index <= _mention.indices[1]
        inline_mention = _mention
        break

    # ensure we found a match
    return unless inline_mention

    # we found it, return it
    inline_mention

  updateMentionsOffset: (e) =>
    return if e.keyCode in KEYS.NO_CHAR

    handleTextManipulation = =>
      selection = new Marbles.DOM.InputSelection @elements.textarea
      _value = @elements.textarea.value
      @once 'keyup', (keyup_event) =>
        new_value = @elements.textarea.value
        return if new_value is _value # nothing changed
        delta = new_value.length - _value.length

        if selection.start != selection.end && delta < 0 && _value.slice(0, selection.start) + _value.slice(selection.end+1, _value.length) == new_value
          # selected text removed
          @updateMentionsOffsetFromIndex(selection.end, delta) # update offset of everything after
          @untrackIndices(selection.start, selection.end) # untrack anything within removed text
        else if delta > 0 && selection.start is selection.end && new_value.slice(0, selection.start) + new_value.slice(selection.start+delta, new_value.length) == _value
          # text inserted after cursor (no selection)
          @updateMentionsOffsetFromIndex(selection.end, delta) # update offset of everything after
        else if _value.slice(0, selection.start) + _value.slice(selection.end, _value.length) == new_value.slice(0, selection.start) + new_value.slice(selection.end + delta, new_value.length)
          # text inserted replacing selected text
          @updateMentionsOffsetFromIndex(selection.end, delta)
          @untrackIndices(selection.start, selection.end)

    if e.ctrlKey
      handleTextManipulation()
      return

    if e.metaKey
      handleTextManipulation()
      return

    if e.keyCode is KEYS.BACKSPACE
      if @current_selection
        offset_delta = (@current_selection.end - @current_selection.start) * -1
      else
        offset_delta = -1
    else
      if @current_selection
        offset_delta = ((@current_selection.end - @current_selection.start) * -1) + 1
      else
        offset_delta = 1

    if @current_selection
      @untrackIndices(@current_selection.start, @current_selection.end)
      index = @current_selection.end + 1
    else
      index = @getCursorPosition()

    @updateMentionsOffsetFromIndex(index, offset_delta)

  updateMentionsOffsetFromIndex: (index, offset_delta) =>
    for pos, mention of @mention_index_mapping
      continue unless pos >= index
      console.log('updateMentionsOffset', offset_delta, JSON.stringify(mention.indices), JSON.stringify(mention.text_indices))
      mention.updateInputIndices(offset_delta)
      delete @mention_index_mapping[pos]
      @mention_index_mapping[mention.indices[0]] = mention

  bindInputEvents: =>
    Marbles.DOM.on @elements.textarea, 'keydown', @processKeyDown
    Marbles.DOM.on @elements.textarea, 'keyup', @processKeyUp

  processKeyDown: (e) =>
    # Prevent manipulation via unix ctrl sequences
    # TODO: handle these sequences
    if e.keyCode is KEYS.DELETE || @_isCtrlT(e) || @_isCtrlU(e) || @_isCtrlY(e) || @_isCtrlW(e) || @_isCtrlM(e) || @_isCtrlK(e) || @_isCtrlH(e) || @_isCtrlD(e)
      e.preventDefault() if @entities.length || @edit_mode_enabled
      return

    selection = new Marbles.DOM.InputSelection @elements.textarea
    if selection.start != selection.end
      @current_selection = selection
    else
      @current_selection = null

      should_return = switch e.keyCode
        when KEYS.BACKSPACE
          @processBackspaceDown(e)
        when KEYS.SPACE
          @processSpaceDown(e)

      return if should_return is true

      unless e.keyCode in KEYS.NO_CHAR
        ##
        # Handle editing an existing inline mention
        index = @getCursorPosition()
        if !@edit_mode_enabled && mention = @findMentionFromPosition(index)
          if not(e.keyCode is KEYS.BACKSPACE) && index is mention.indices[1]
          else
            @editMention(mention, index, e)

    @updateMentionsOffset(e)

  processBackspaceDown: (e) =>
    ##
    # Handle backspacing ^ (start of inline mention currently being edited)
    if @edit_mode_enabled && @getCursorPosition() is @current_start_index
      @untrackMention(@current_mention) if @current_mention
      @current_mention = null
      @disableEditMode()
      return true

    null

  processSpaceDown: (e) =>
    return unless @edit_mode_enabled

    pos = @getCursorPosition()
    input = @elements.textarea.value.slice(@current_start_index, pos)
    if input.match(/^https?:\/\//)
      @createMention(@current_start_index, pos, entity: input, display_text: TentStatus.Helpers.formatUrlWithPath(input), input_text: input)
      @disableEditMode()
      @updateMentionsOffset(e)
      return true
    else
      @disableEditMode()

    null

  processKeyUp: (e) =>
    @trigger 'keyup', e

    if !@edit_mode_enabled && @_isCarret(e)
      @current_start_index = @getCursorPosition()
      @enableEditMode()

class InlineMention extends Marbles.Object
  renderMarkdown: =>
    markdown = "[#{@text}](#{@entity_index})"

  updateInputIndices: (delta) =>
    @indices[0] += delta
    @indices[1] += delta
    @text_indices[0] += delta
    @text_indices[1] += delta

