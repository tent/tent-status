TentStatus.Object = class Object
  constructor: (attributes) ->
    @set(k, v) for k,v of attributes

_.extend Object::, TentStatus.Accessors, TentStatus.Events
