# Description:
#   force remove score()
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot force erase

ScoreKeeper = require('hubot-plusplus/src/scorekeeper')

module.exports = (robot) ->
  scoreKeeper = new ScoreKeeper(robot)
  robot.respond /force erase (.*)/i, (msg) ->
    name = msg.match[1]
    from = msg.message.user.name.toLowerCase()
    room = msg.message.room

    erased = scoreKeeper.erase(name, from, room, undefined)
    if erased?
      message = "Erased points for #{name}"
      msg.send message
