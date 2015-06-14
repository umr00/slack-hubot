DeleteBrain = require('./delete-brain')

module.exports = (robot) ->
	brain = new DeleteBrain(robot)
	robot.hear /(\S*)/i, (msg) ->
		current_time = new Date().getTime()
		delete_interval = 2*1000*60*60
		if current_time - brain.get_time() > delete_interval
			brain.set_time(current_time)
			keys = Object.keys(brain.get())
			for key in keys
				value = brain.get()[key]
				messages = []
				for message in value
					message.iv ||= delete_interval
					if current_time - key > message.iv
						robot.adapter.client._apiCall 'chat.delete',
							channel: message.ch
							ts: message.ts
						, (res) -> null
					else
						messages.push(message)
				if messages.length == 0
					brain.remove(key)
				else
					brain.update(key, messages)

	robot.respond /delete list/i, (msg) ->
		result = ""
		for key, value of brain.get()
			for message in value
				result += message.ts + " : " + message.ch + " : " + message.iv + "\n"
		msg.send result
