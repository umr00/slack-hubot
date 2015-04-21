TextMessage = require('hubot').TextMessage
module.exports = (robot) ->
	robot.hear /^image (.*)/i, (msg) ->
		robot.receive new TextMessage(msg.message.user, "slackbot image #{msg.match[1]}", "image")

	robot.hear /^animate (.*)/i, (msg) ->
		robot.receive new TextMessage(msg.message.user, "slackbot animate #{msg.match[1]}", "image")
