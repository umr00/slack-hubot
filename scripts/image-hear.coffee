botName = process.env.HUBOT_SLACK_BOTNAME
TextMessage = require('hubot').TextMessage
module.exports = (robot) ->
	robot.hear /^image (.*)/i, (msg) ->
		robot.receive new TextMessage(msg.message.user, "#{botName} image #{msg.match[1]}", "image")

	robot.hear /^animate (.*)/i, (msg) ->
		robot.receive new TextMessage(msg.message.user, "#{botName} animate #{msg.match[1]}", "image")
