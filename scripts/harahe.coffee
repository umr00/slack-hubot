# Description:
#   get starved
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   はらへ - Show food image

botName = process.env.HUBOT_SLACK_BOTNAME
TextMessage = require('hubot').TextMessage
module.exports = (robot) ->
  robot.hear /はらへ/i, (msg) ->
    words = [
        '餃子'
        'ラーメン'
        'からあげ'
        '焼肉'
    ]
    robot.receive new TextMessage(msg.message.user, "#{botName} image #{words[Math.floor(Math.random() * 3)]}", "image")
