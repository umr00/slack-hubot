# Description:
#   hubot will decide for you
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot decide <your choices>
#   hubot decide <number> from <your choices>

module.exports = (robot) ->
  robot.respond /(suggest|choose|pick|select|decide)\s*(\d*\s*(from|amongst|between|among|amongst|out of))? (.+)/i, (msg) ->
    choices = msg.match[4]
    choiceList = choices.toString().split(/\s/)
    numberOfPicks = msg.match[2] || "1"
    numberOfPicks = parseInt(numberOfPicks.toString().split(/\s/)[0])
    if numberOfPicks <= 0 || numberOfPicks > choiceList.length
      msg.send 'I am confused. Number of picks should be less or equal to the number of options.'
    else
      # choiceList.sort (a,b) -> .5 - Math.random()
      shuffle choiceList
      picks = choiceList[0..(numberOfPicks-1)]
      msg.send picks.join(', ')

shuffle = (a) ->
  i = a.length
  while --i > 0
    j = ~~(Math.random() * (i + 1))
    t = a[j]
    a[j] = a[i]
    a[i] = t
  a
