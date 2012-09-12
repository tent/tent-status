require '/spec_helper.js'
require '/application.js'

describe 'NewPostForm', ->
  describe 'buildDataObject', ->
    it 'should merge multiple values for name into array', ->
      postForm = new StatusPro.Views.NewPostForm
      serializedArray = [
        { name: 'somekey', value: 'val1' },
        { name: 'somekey', value: 'val2' },
        { name: 'somekey', value: 'val3' },
      ]

      data = postForm.buildDataObject(serializedArray)
      expect(data).toEqual({
        'somekey': ['val1', 'val2', 'val3'],
        permissions:
          public: false
          groups: []
          entities: {}
      })

    it 'should build permissions object', ->
      postForm = new StatusPro.Views.NewPostForm
      serializedArray = [
        { name: 'public', value: 'on' },
        { name: 'permissible_groups', value: 'groupId1' },
        { name: 'permissible_groups', value: 'groupId2' },
        { name: 'permissible_entities', value: 'entity1' },
      ]

      data = postForm.buildDataObject(serializedArray)
      expect(data).toEqual({
        permissions:
          public: true
          groups: [
            { id: 'groupId1' }, { id: 'groupId2' }
          ]
          entities:
            'entity1': true
      })
