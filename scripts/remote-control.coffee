# Description:
#   Bot will speak in the #general when you operate from #hubot-test
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   say

module.exports = (robot) ->
  robot.respond /say (.*)/, (msg) ->
    unless msg.envelope.room == 'hubot-test'
      return
    robot.messageRoom 'general', "#{msg.match[1]}"

