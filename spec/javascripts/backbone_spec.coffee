require '/spec_helper.js'
require '/underscore.js'
require '/backbone.js'

describe 'Backbone.Events', ->
  describe 'once', ->
    it 'should fire once then remove itself', ->
      callback = sinon.spy()
      obj = _.extend({}, Backbone.Events)
      obj.once 'alert', callback
      obj.trigger 'alert'
      obj.trigger 'alert'
      expect(callback.calledOnce).toEqual(true)

