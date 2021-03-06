# Description:
#   Search for train transfer
# Commands:
#   mika4 新宿→東京

moment = require "moment"

module.exports = (robot) ->
  robot.respond /([^0-9a-zA-Z]+)→([^0-9a-zA-Z\s]+)(?:\s*)(\u59CB\u767A){0,}(\u7D42\u96FB){0,}/i, (msg) ->
    cway = 0
    trainType = "乗り換え"
    if msg.match[3]
      cway = 2 # 始発
      trainType = msg.match[3]
    else if msg.match[4]
      cway = 3 # 終電
      trainType = msg.match[4]
    url = "http://www.jorudan.co.jp/norikae/cgi/nori.cgi?Sok=1&eki1=#{msg.match[1]}&eki2=#{msg.match[2]}&type=t&Cway=#{cway}"
    msg.http(url).get() (err, res, body) ->
      msg.send "#{trainType}しらべるよぉ"
      if /(■[\s\S]*?■.+)/.test(body)
        text = RegExp.$1
        msg.send text
        if /(\d{2}:\d{2})/.test(text)
          next = new moment(RegExp.$1, "HH:mm")
          current = new moment()
          limit = next.diff(current, "minutes") + 1
          if limit < 0
            if limit < -1440
              msg.send "今日の電車はもうないよぉ…(´；ω；｀)"
              return
            else
              limit = limit + 1440

          msg.send "あと#{limit}分だよぉ！=͟͟͞͞( ・∀・)"
      else
        msg.send "わからない経路だよぉ(>_<)"
