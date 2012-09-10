require '/spec_helper.js'
require '/http.js'

describe 'HTTP', ->
  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  describe 'get', ->
    it 'should GET uri and pass response to callback', ->
      obj = { foo: 'bar' }
      @server.respondWith "GET", "/foo/bar",
        [200, { 'Content-Type': 'application/json' }, JSON.stringify(obj)]

      callback = sinon.spy()
      HTTP.get('/foo/bar', callback)
      @server.respond()

      expect(callback.calledOnce).toEqual(true)
      sinon.assert.calledWith(callback, obj)
