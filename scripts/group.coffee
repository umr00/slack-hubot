# Description:
#   manage group
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot add group <group name> <user name> ... - add user to group (create group if it doesn't exist)
#   hubot remove group <group name> <user name> ... - remove user from group
#   hubot remove group <group name> - remove group
#   hubot list group - list all group
#   hubot list group <group name> - list all user in group
#   @group_name <text> - send mention to all group users

GroupBrain = require('./group-brain')

module.exports = (robot) ->
  brain = new GroupBrain(robot)

  robot.hear /@(\S+)/i, (msg) ->
    groupName = msg.match[1]
    if brain.hasGroup(groupName)
      userArray = brain.getGroup(groupName)
      messageText = ""
      for u in userArray
        messageText += "@#{u} "
      msg.send messageText

  robot.respond /list group(\s+(\S+))?/i, (msg) ->
    if msg.match[1]?
      groupName = msg.match[2]
      if !brain.hasGroup(groupName)
        msg.send "No such group #{groupName}"
      else
        userArray = brain.getGroup(groupName)
        msg.send "#{userArray.join()}"
    else
      groupDict = brain.get()
      keys = Object.keys(groupDict)
      keys.sort()
      listText = ""
      for k in keys
        listText += k + " : " + groupDict[k].join() + "\n"
      listText = listText.substring(0, listText.length - 1)
      msg.send listText

  robot.respond /add group\s+(\S+)\s+((\S|\s)+)/i, (msg) ->
    groupName = msg.match[1]
    addUserArray = msg.match[2].split(" ").filter(Boolean).unique()
    if !brain.hasGroup(groupName)
      userArray = addUserArray
      msg.send updateGroup(brain, groupName, userArray)
    else
      userArray = brain.getGroup(groupName).concat addUserArray
      userArray = userArray.filter(Boolean).unique()
      msg.send updateGroup(brain, groupName, userArray)

  robot.respond /remove group\s+(\S+)(\s+((\S|\s)+))?/i, (msg) ->
    groupName = msg.match[1]
    if !brain.hasGroup(groupName)
      msg.send "No such group #{groupName}"
      return

    if !msg.match[2]?
      brain.remove(groupName)
      msg.send "Removed group #{groupName}"
    else
      removeUserArray = msg.match[3].split(" ").filter(Boolean).unique()
      userArray = brain.getGroup(groupName)
      userArray = userArray.diff(removeUserArray)
      msg.send updateGroup(brain, groupName, userArray)

updateGroup = (brain, groupName, userArray) ->
  text = "Created"
  if brain.hasGroup(groupName)
    text = "Updated"

  brain.update(groupName, userArray)
  return "#{text} group #{groupName}\n#{groupName} : #{userArray.join()}"

Array::diff = (array)-> (value for value in this when array.indexOf(value) is -1)

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output
