# Description:
#   Get image from tumblr
# Commands:
#   mika4 (.+)画像はよ
#   mika4 (.+)画像はよ!!

tumblr = require "tumblrbot"

module.exports = (robot) ->
  robot.respond /(?:(.+)画像)(?:はよ|クレメンス|くれ)((?:\uFF01|!){0,})/i, (msg) ->
    msg.send "ちょっとまってね〜"
    maxCount = 4
    count = 1
    if msg.match[2]
      if msg.match[2].length <= maxCount
        count = msg.match[2].length
      else
        count = maxCount
    limitMaxCount = 30
    limitCount = 1
    imageFound = false
    url = "https://api.mlab.com/api/1/databases/#{process.env.database}/collections/#{process.env.collection_tumblr_config}"
    url+= "?apiKey=#{process.env.apikey}&q={\"keyword\":\"" + msg.match[1] + "\"}"

    notFound = () ->
      msg.send "…画像がみつからないよぉ( ꒪⌓꒪)"

    getConfig = (callback) ->
      msg.http(url)
        .get() (err, res, body) ->
          if err
            notFound()
          else
            json = JSON.parse(body)
            if json.length == 0
              notFound()
            else
              callback json

    getIndex = (list) ->
      parseInt Math.random() * list.length - 1, 10

    getImage = (config, imgNum) ->
      if imgNum > count || limitCount > limitMaxCount
        notFound() unless imageFound
        return

      id = config.id[getIndex config.id]
      tag = config.tag

      tumblr.photos(id + ".tumblr.com").random { tag: tag }, (post) ->
        if post
          msg.send post.photos[0].original_size.url
          imageFound = true
          imgNum++
        limitCount++
        getImage config, imgNum

    getConfig((configList) ->
      config = configList[getIndex configList]
      if config.keyword == msg.match[1]
        getImage config, 1
    )
