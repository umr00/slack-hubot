DeleteBrain = require('./delete-brain')

class AutoDeleteMessage
	constructor: (@robot, @channel) ->
		@brain = new DeleteBrain(@robot)

	post_with_day: (text, current_time, day) ->
		this.post(text, current_time, day*1000*60*60*24)

	post_with_hour: (text, current_time, hour) ->
		this.post(text, current_time, hour*1000*60*60)

	post: (text, current_time, delete_interval) ->
		@robot.adapter.client._apiCall 'chat.postMessage',
			channel: @channel
			text: text
			as_user: true
		, (res) => @brain.add(current_time, @channel, res.ts, delete_interval)

module.exports = AutoDeleteMessage
