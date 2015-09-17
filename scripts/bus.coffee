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
  count = Math.min(5, count)
  count = Math.max(1, count)
  current = new Date()
  hour = current.getHours()
  min = current.getMinutes()
  dict = timeDict(current.getDay() == 0 || current.getDay() == 6)

  num = 0
  str = ""
  while count > num
    break if hour > 23
    if dia[dest][hour]?
      list = dia[dest][hour]
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
  dest == "kita" || dest == "gaku" || dest == "taka"

availableDest = () ->
  "kita : 学研北生駒\ngaku : 学園前\ntaka : 高の原"

keysFromDestination = (dest) ->
  dict = {
    "kita" : ["kita", "gaku"]
    "gaku" : ["gaku"]
    "taka" : ["taka"]
  }
  dict[dest]

timeDict = (holiday) ->
  if !holiday
    dict = {
      6   : {"kita" : [],         "gaku" : [16,52],   "taka" : [17]}
      7   : {"kita" : [20,44],    "gaku" : [39],      "taka" : [19]}
      8   : {"kita" : [7,17,49],  "gaku" : [24],      "taka" : [29]}
      9   : {"kita" : [],         "gaku" : [12],      "taka" : [15]}
      10  : {"kita" : [],         "gaku" : [2],       "taka" : [12]}
      11  : {"kita" : [],         "gaku" : [2],       "taka" : [38]}
      12  : {"kita" : [],         "gaku" : [2],       "taka" : []}
      13  : {"kita" : [],         "gaku" : [2],       "taka" : [38]}
      14  : {"kita" : [],         "gaku" : [2],       "taka" : []}
      15  : {"kita" : [],         "gaku" : [12],      "taka" : [13]}
      16  : {"kita" : [],         "gaku" : [2],       "taka" : [48]}
      17  : {"kita" : [17,57],    "gaku" : [0,43],    "taka" : [36]}
      18  : {"kita" : [24,49],    "gaku" : [7,37],    "taka" : [54]}
      19  : {"kita" : [29],       "gaku" : [2],       "taka" : [38]}
      20  : {"kita" : [27,56],    "gaku" : [6],       "taka" : [48]}
      21  : {"kita" : [],         "gaku" : [32],      "taka" : []}
      22  : {"kita" : [2],        "gaku" : [],        "taka" : []}
    }
  else
    dict = {
      6   : {"kita" : [16],       "gaku" : [49],      "taka" : []}
      7   : {"kita" : [58],       "gaku" : [28],      "taka" : []}
      8   : {"kita" : [24, 49],   "gaku" : [],        "taka" : [29]}
      9   : {"kita" : [],         "gaku" : [22],      "taka" : [15]}
      10  : {"kita" : [],         "gaku" : [],        "taka" : [12]}
      11  : {"kita" : [],         "gaku" : [2],       "taka" : [38]}
      12  : {"kita" : [],         "gaku" : [],        "taka" : []}
      13  : {"kita" : [],         "gaku" : [2],       "taka" : [38]}
      14  : {"kita" : [],         "gaku" : [],        "taka" : []}
      15  : {"kita" : [],         "gaku" : [12],      "taka" : [13]}
      16  : {"kita" : [],         "gaku" : [],        "taka" : [48]}
      17  : {"kita" : [17,47],    "gaku" : [1],       "taka" : [36]}
      18  : {"kita" : [17,57],    "gaku" : [31],      "taka" : [54]}
      19  : {"kita" : [27,56],    "gaku" : [],        "taka" : []}
      20  : {"kita" : [27,57],    "gaku" : [],        "taka" : []}
      21  : {"kita" : [27],       "gaku" : [],        "taka" : []}
      22  : {"kita" : [],         "gaku" : [],        "taka" : []}
    }
