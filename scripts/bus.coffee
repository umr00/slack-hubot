# Description:
#   show next bus time
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   bus <destination> <count> - Show next <count> time
fs = require 'fs'
path = require 'path'

file = path.join(process.cwd(), 'time_table.json')
dia = JSON.parse(fs.readFileSync(file, 'utf8'))

module.exports = (robot) ->
  robot.hear /^bus (\w+)( (\d+))?/i, (msg) ->
    if !destAvailable(msg.match[1])
      msg.send availableDest()
    else
      str = nextBus(msg.match[1], msg.match[2], msg)
      if str != ""
        msg.send str
      else
        msg.send "本日の運行は終了しました"

nextBus = (dest, count, msg) ->
  count = parseInt(count, 10) || 3
  count = Math.max(1, count)
  current = new Date()
  hour = current.getHours()
  min = current.getMinutes()
  if current.getDay() == 0 || current.getDay() == 6
    day = "holiday"
  else
    day = "weekday"

  num = 0
  str = ""
  time_table = dia[day]
  while count > num
    break if hour > 23
    if time_table[dest][hour]?
      list = time_table[dest][hour]
      for time in list
        break if num >= count
        if time > min
          str += "#{hour}時#{time}分, "
          num++
    min = -1
    hour++
  str = str.substring(0, str.length - 2)
  str

destAvailable = (dest) ->
  dest == "kita" || dest == "gaku" || dest == "taka" || dest == "tiku"

availableDest = () ->
  "kita : 学研北生駒\ngaku : 学園前\ntaka : 高の原\ntiku : 地区センターから学園前"

keysFromDestination = (dest) ->
  dict = {
    "kita" : ["kita", "gaku"]
    "gaku" : ["gaku"]
    "taka" : ["taka"]
  }
  dict[dest]
