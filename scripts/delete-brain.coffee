class DeleteBrain
  constructor: (@robot) ->
    storageLoaded = =>
      @storage = @robot.brain.data.deleteBrain ||= {
        last_time : new Date().getTime()
        messages : {}
      }
      @robot.logger.debug "Delete Brain Data Loaded: " + JSON.stringify(@storage, null, 2)
    @robot.brain.on "loaded", storageLoaded
    storageLoaded() # just in case storage was loaded before we got here

  get_time: ->
    @storage.last_time

  set_time: (time) ->
    @storage.last_time = time
    @robot.brain.save()

  get: ->
    @storage.messages

  add: (time, channel, timestamp, delete_interval) ->
    data = {
      ts : timestamp
      ch : channel
      iv : delete_interval
    }
    @storage.messages[time] ||= []
    @storage.messages[time].push(data)
    @robot.brain.save()

  update: (key, messages) ->
    @storage.messages[key] = messages
    @robot.brain.save()

  remove: (time) ->
    delete @storage.messages[time]
    @robot.brain.save()

module.exports = DeleteBrain
