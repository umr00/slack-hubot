# Description:
#   get starved
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   はらへ - Show food image

module.exports = (robot) ->
  robot.hear /はらへ/i, (msg) ->
    words = [
        '餃子'
        'ラーメン'
        'からあげ'
    ]
    imageMe msg, words[Math.floor(Math.random() * 3)], (url) ->
       msg.send url

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = v: '1.0', rsz: '8', q: query, safe: 'active'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image  = msg.random images
        cb "#{image.unescapedUrl}#.png"
