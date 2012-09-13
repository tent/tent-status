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

  describe 'post', ->
    it 'should POST uri with data and csrf token, and pass response to callback', ->
      window.StatusPro = {csrf_token: 'csrf-token'}
      data = { foo: 'bar' }
      @server.respondWith "POST", "/bar/baz",
        [200, { 'Content-Type': 'application/json' }, JSON.stringify(data)]

      callback = sinon.spy()
      HTTP.post('/bar/baz', data, callback)
      @server.respond()

      expect(callback.calledOnce).toEqual(true)
      expect(callback.args[0][0]).toEqual(data)
