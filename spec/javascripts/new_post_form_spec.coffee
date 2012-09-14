require '/spec_helper.js'
require '/application.js'

describe 'NewPostForm', ->
  describe 'buildDataObject', ->
    it 'should merge multiple values for name into array', ->
      postForm = new StatusApp.Views.NewPostForm
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
      })

    it 'should build permissions object', ->
      postForm = new StatusApp.Views.NewPostForm
      serializedArray = [
        { name: 'public', value: 'on' },
        { name: 'permissions', value: 'g:groupId1' },
        { name: 'permissions', value: 'g:groupId2' },
        { name: 'permissions', value: 'f:entity1' },
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
