DeleteBrain = require('./delete-brain')

module.exports = (robot) ->
	brain = new DeleteBrain(robot)
	robot.hear /(\S*)/i, (msg) ->
		current_time = new Date().getTime()
		delete_interval = 7200000
		if current_time - brain.get_time() > delete_interval
			brain.set_time(current_time)
			for key, value of brain.get()
				if current_time - key > delete_interval
					for message in value
						robot.adapter.client._apiCall 'chat.delete',
							channel: message.ch
							ts: message.ts
						, (res) -> null
					brain.remove(key)

	robot.respond /delete list/i, (msg) ->
		result = ""
		for key, value of brain.get()
			for message in value
				result += message.ts + " : " + message.ch + "\n"
		msg.send result
