class GroupBrain
  constructor: (@robot) ->
    storageLoaded = =>
      @storage = @robot.brain.data.groupBrain ||= {}
      @robot.logger.debug "Group Brain Data Loaded: " + JSON.stringify(@storage, null, 2)
    @robot.brain.on "loaded", storageLoaded
    storageLoaded() # just in case storage was loaded before we got here

  get: ->
    @storage

  getGroup: (key) ->
    @storage[key]

  hasGroup: (key) ->
    @storage[key]?

  update: (key, list) ->
    @storage[key] = list
    @robot.brain.save()
    true

  remove: (key) ->
    delete @storage[key]
    true

module.exports = GroupBrain
