module.exports = (robot) ->
  robot.respond /(tiqav|tiq)( me)? (.*)/i, (msg) ->
    robot.http("http://api.tiqav.com/search.json?q=#{encodeURIComponent msg.match[3]}")
      .get() (err, res, body) ->
        body = JSON.parse body
        img = body[0]
        msg.send "http://img.tiqav.com/#{img.id}.#{img.ext}"

