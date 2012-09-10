require '/spec_helper.js'
require '/application.js'

describe 'StatusPro', ->
  beforeEach ->
    @server = sinon.fakeServer.create()

    @templates = {
      hello: "Hello {{world}}"
    }

  afterEach ->
    @server.restore()

  describe 'fetchTemplate', ->
    it 'should fetch, compile, and cache mustache template', ->
      @server.respondWith "GET", "/assets/templates/hello.html.mustache",
        [200, { 'Content-Type': 'text/plain' }, @templates.hello]

      callback = sinon.spy()
      StatusPro.fetchTemplate 'hello', callback
      @server.respond()

      expect(callback.calledOnce).toEqual(true)
      expect(callback.getCall(0).args[0]).toEqual(Hogan.compile(@templates.hello))
      expect(callback.getCall(0).args[0].render({ world: 'World' })).toEqual('Hello World')

      # it should cache templates
      callback = sinon.spy()
      StatusPro.fetchTemplate 'hello', callback
      expect(callback.calledOnce).toEqual(true)
      expect(callback.getCall(0).args[0]).toEqual(Hogan.compile(@templates.hello))
      expect(callback.getCall(0).args[0].render({ world: 'World' })).toEqual('Hello World')
