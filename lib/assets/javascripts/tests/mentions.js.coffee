mentions_text = "^https://daniel.tent.is ^https://lorenb.tent.is I do think folks expect to have mentions in-line. Still like the idea of a preferred name: average user doesn't care about carets, protocol scheme, domains. That stuff should be under the hood. ^tent ^bent ^kent. ^https://shawnj.tent.is/ ^https://jyap.tent.is/ https, https https, ^tent ,https You know you are part of something new when you refresh the Site Feed (see what I did there ^74thrule.74thrule.com?) and the new posts take up one page. Testing a mid-status mention of ^eolai as opposed to ^eolai.tent.is ^joakim.io ^jamie-tent.herokuapp.com ^marco ^marcof ^DeMo"

expected_mentions = [
  {entity: "https://daniel.tent.is"           , text: "https://daniel.tent.is"},
  {entity: "https://lorenb.tent.is"           , text: "https://lorenb.tent.is"},
  {entity: "https://shawnj.tent.is/"          , text: "https://shawnj.tent.is/"},
  {entity: "https://jyap.tent.is/"            , text: "https://jyap.tent.is/"},
  {entity: "https://74thrule.74thrule.com"    , text: "74thrule.74thrule.com"},
  {entity: "https://eolai.tent.is"            , text: "eolai.tent.is"},
  {entity: "https://tent.74thrule.com"        , text: "tent"},
  {entity: "https://bent.74thrule.com"        , text: "bent"},
  {entity: "https://kent.74thrule.com"        , text: "kent"},
  {entity: "https://joakim.io"                , text: "joakim.io"},
  {entity: "https://jamie-tent.herokuapp.com" , text: "jamie-tent.herokuapp.com"},
  {entity: "https://marco.74thrule.com"       , text: "marco"},
  {entity: "https://marcof.74thrule.com"      , text: "marcof"},
  {entity: "https://demo.74thrule.com"        , text: "DeMo"}
]

testExtractMentionsWithIndices = ->
  actual_mentions = TentStatus.Helpers.extractMentionsWithIndices(mentions_text)
  for expected_m in expected_mentions
    match = null
    for m in actual_mentions
      if expected_m.entity == m.entity
        match = m
        break
    unless match
      console.error "Expected #{expected_m.entity} to be matched"
    else
      unless match.text == expected_m.text
        console.error "Expected #{match.text} to be #{expected_m.text}"
  console.log "Actual (#{actual_mentions.length}):", actual_mentions, "Expected (#{expected_mentions.length}):", expected_mentions

@test = {
  extractMentionsWithIndices: testExtractMentionsWithIndices
}
