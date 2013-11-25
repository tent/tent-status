class TentStatus.InlineMentionsManager extends Marbles.Object
  constructor: (options = {}) ->
    @elements = {
      textarea: options.el
    }

    @entities = []
    @inline_mentions = {}
    @excess_char_count = 0

    @bindInputEvents()

  bindInputEvents: =>
    Marbles.DOM.on @elements.textarea, 'keydown', @processKeyDown

  processedMarkdown: =>
    @updateMentions()

    text = @elements.textarea.value

    offset = 0

    for entity, inline_mentions of @inline_mentions
      for inline_mention in inline_mentions
        mention_markdown = inline_mention.toMarkdownString()
        text = text.slice(0, inline_mention.start_index + offset) + mention_markdown + text.slice(inline_mention.end_index + offset, text.length)

        offset -= inline_mention.input_text.length - mention_markdown.length

    text

  processKeyDown: (e) =>
    clearTimeout @_update_mentions_timeout
    @_update_mentions_timeout = setTimeout @updateMentions, 10

  updateMentions: =>
    value = @elements.textarea.value
    length = value.length
    offset = 0

    regex = /(\^\[([^\]]*)\]\(([^\)]*)\))/

    entities = []
    inline_mentions = {}
    excess_char_count = 0

    while (_val = value.slice(offset, length)) && (index = _val.search(regex)) != -1
      m = _val.match(regex)
      input_text = m[1]
      display_text = m[2]
      entity = m[3]

      start_index = offset + index
      end_index = start_index + input_text.length

      offset += index + input_text.length

      entities.push(entity) if entities.indexOf(entity) == -1

      inline_mention = new @constructor.InlineMention(
        start_index: start_index
        end_index: end_index
        input_text: input_text
        display_text: display_text
        entity: entity
        entity_index: entities.indexOf(entity)
      )

      # the entity URI will be replaces with an index,
      # keep track of the number of chars exceeding the length of all the indices
      excess_char_count += TentStatus.Helpers.numChars(entity) - inline_mention.entity_index.toString().length

      inline_mentions[entity] ?= []
      inline_mentions[entity].push(inline_mention)

    @set 'entities', entities
    @set 'inline_mentions', inline_mentions
    @set 'excess_char_count', excess_char_count

  @InlineMention = class InlineMention extends Marbles.Object
    constructor: (properties) ->
      (@[k] = v) for k,v of properties

    toMarkdownString: =>
      "^[#{@display_text}](#{@entity_index})"

    toExpandedMarkdownString: =>
      "^[#{@display_text}](#{@entity})"

