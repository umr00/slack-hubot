class ImageBrain
  constructor: (@robot) ->
    storageLoaded = =>
      @storage = @robot.brain.data.imageBrain ||= {}
      @robot.logger.debug "Image Brain Data Loaded: " + JSON.stringify(@storage, null, 2)
    @robot.brain.on "loaded", storageLoaded
    storageLoaded() # just in case storage was loaded before we got here

  get: ->
    @storage

  add: (key, value) ->
    @storage[key] = value
    @robot.brain.save()
    true

  remove: (key) ->
    delete @storage[key]
    true

class ZoiBrain extends ImageBrain
  constructor: (@robot) ->
    storageLoaded = =>
      @storage = @robot.brain.data.zoiBrain ||= {}
      @robot.logger.debug "Zoi Brain Data Loaded: " + JSON.stringify(@storage, null, 2)
    @robot.brain.on "loaded", storageLoaded
    storageLoaded() # just in case storage was loaded before we got here

class StampBrain extends ImageBrain
  constructor: (@robot) ->
    storageLoaded = =>
      @storage = @robot.brain.data.stampBrain ||= {}
      @robot.logger.debug "Stamp Brain Data Loaded: " + JSON.stringify(@storage, null, 2)
    @robot.brain.on "loaded", storageLoaded
    storageLoaded() # just in case storage was loaded before we got here

module.exports = {
  ImageBrain
  ZoiBrain
  StampBrain
}
