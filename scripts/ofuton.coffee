# Description:
#   get to sleep
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   くそねむ - Get to sleep

module.exports = (robot) ->
  robot.hear /くそねみ/i, (msg) ->
    msg.send "ｵﾌﾄｩﾝ(:3[____]"

