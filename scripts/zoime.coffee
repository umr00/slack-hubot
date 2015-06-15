# Description:
#   zoi is the most important thing in your life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   zoi <name> - Receive zoi
#   zoi help - Show all zoi
#   sdbot add zoi <key> <value> - Add to zoi
#   sdbot remove zoi <key> - Remove from zoi

helpers = require('coffee-script/lib/coffee-script/helpers')
validator = require('validator')
{ZoiBrain} = require('./image-brain')
AutoDeleteMessage = require('./auto-delete-post')

module.exports = (robot) ->
  brain = new ZoiBrain(robot)

  robot.respond /add zoi\s+(\S+)\s+(https?:\/\/.+)/i, (msg) ->
    if validator.isURL(msg.match[2])
      key = msg.match[1]
      brain.add(msg.match[1], msg.match[2])
      msg.send "Add #{key} to zoi"
    else
      msg.send "#{msg.match[2]} is not a valid URL"

  robot.respond /remove zoi (\S+)/i, (msg) ->
    key = msg.match[1]
    brain.remove(msg.match[1])
    msg.send "Remove #{key} from zoi"

  robot.hear /^zoi (.*)/i, (msg) ->
    name = msg.match[1]
    zois = {
      'おはようございます' : 'https://pbs.twimg.com/media/Bs7qd4uCAAAwalT.jpg:large'
      'ありがとうございます':'https://pbs.twimg.com/media/BtcSDbWCQAADuhK.jpg:large'
      'きゅうけいする' : 'https://pbs.twimg.com/media/BswuUTPCYAAVX5n.jpg:large'
      'ごはんにする' : 'https://pbs.twimg.com/media/BtcSOp6CcAA9_b4.jpg:large'
      'やすむ':'https://pbs.twimg.com/media/BspWoBQCcAAm9y5.jpg:large'
      'ねる':'https://pbs.twimg.com/media/BtcSM8BCYAE3_8j.jpg:large'
      'もう夜' : 'https://pbs.twimg.com/media/BswuLr2CMAA1SpE.jpg:large',
      'きたく' : 'https://pbs.twimg.com/media/BtcSRdRCMAArUCS.jpg:large',
      'あきらめる' : 'https://pbs.twimg.com/media/BtcSIHmCUAA8Prp.jpg:large'
      'がんばるぞい' : 'https://pbs.twimg.com/media/BspTawrCEAAwQnP.jpg:large'
      'がんばる' : 'https://pbs.twimg.com/media/BspWSkvCAAAMi43.jpg:large'
      'やった' : 'https://pbs.twimg.com/media/Bts7BNsCMAASKsP.jpg:large'
      'だめだ' : 'https://pbs.twimg.com/media/BspWc7LCAAAPzhS.jpg:large'
      'ぐーたらする' : 'https://pbs.twimg.com/media/BspWlZFCMAA4fmV.jpg:large'
      'いけるきがする':'https://pbs.twimg.com/media/BswuNkICcAE4olR.jpg:large'
      '進捗':'http://pic.non117.com/C/ch.jpg'
      '土下座':'http://anfield.blog.ocn.ne.jp/gorimuchu/images/2014/03/21/new_game_01_p011_2.jpg'
      'がんばれた':'https://pbs.twimg.com/media/B48WE_XIIAAqDls.jpg'
    }

    brainDict = brain.get()
    zois = helpers.merge(zois, brainDict)

    help = createHelp(zois)
    channel = robot.adapter.client.getChannelGroupOrDMByName(msg.envelope.room)?.id
    time = new Date().getTime()

    if name == "help"
      new AutoDeleteMessage(robot, channel).post_with_day("#{help}", time, 1)
    else
      result = zois[name]
      if result
        new AutoDeleteMessage(robot, channel).post_with_day("#{result}", time, 1)
      else
        new AutoDeleteMessage(robot, channel).post_with_day("#{name}はないぞい", time, 1)

createHelp = (dict) ->
  keys = Object.keys(dict)
  keys.sort()
  help = ""
  for k in keys
    help += k + "\n"
  help = help.substring(0, help.length - 1)
  help
