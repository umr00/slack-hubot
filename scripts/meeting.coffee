cronJob = require('cron').CronJob

module.exports = (robot) ->
  send = (room, msg) ->
    response = new robot.Response(robot, {user : {id : -1, name : room}, text : "none", done : false}, [])
    response.send msg

  # *(sec) *(min) *(hour) *(day) *(month) *(day of the week)
  new cronJob('0 5 15 * * 1', () ->
    currentTime = new Date
    send '#general', "@channel Time for Rinko!"
  ).start()

  new cronJob('0 5 15 * * 3', () ->
    currentTime = new Date
    send '#general', "@channel Time for Meeting & Rinko!"
  ).start()
