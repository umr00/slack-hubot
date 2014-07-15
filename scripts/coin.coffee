# Description:
#   Help decide between two things
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot throw coin - Gives you heads or tails
#
# Author:
#   mrtazz

thecoin = ["heads", "tails"]

module.exports = (robot) ->
  robot.respond /(throw|flip|toss) coin/i, (msg) ->
    msg.reply msg.random thecoin
