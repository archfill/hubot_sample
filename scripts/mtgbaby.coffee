cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob
request = require('request')

heroku_config = messages: JSON.parse(process.env.HUBOT_USER_CONFIG ? '[]')

module.exports = (robot) ->

  # 全体
  robot.hear /train (.+)/i, (msg) ->
    room = msg.message.user.room

    # チャンネル指定
    # hiedabottest
    # notifications
    if room == "C55RDV935" or room == "C51N74CLS"
      searchMain(msg)

 # 個人宛
  robot.respond /train (.+)/i, (msg) ->
    searchMain(msg)

  searchMain = (msg) ->
    target = msg.match[1]

    if target == "all"
      searchAllTrain(msg)
    else if target == 'a.nagura'
      msg.send "登録してないよ。"
    else
      msg.send "#{target}はわかりません。(´･ω ･`)"

  searchTrain = (url, msg) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        msg.send "#{title}は遅れてないよ。"
      else
        info = $('.trouble p').text()
        msg.send "#{title}は遅れているみたい。\n#{info}"

  # new cronJob('0 30 7 * * 1-5', () ->
  #   searchTrainCron(nagoya_higashiyama)
  #   searchTrainCron(nagoya_meijo)
  #   searchTrainCron(nagoya_turumai)
  #   searchTrainCron(nagoya_sakuradori)
  #   searchTrainCron(nagoya_kamiiida)
  #   searchTrainCron(nagoya_meikou)
  #   searchTrainCron(meitetsu_inuyama)
  # null,
  # true,
  # "Asia/Tokyo"
  # ).start()
  #
  # searchTrainCron = (url) ->
  #   cheerio.fetch url, (err, $, res) ->
  #     title = "#{$('h1').text()}"
  #     if $('.icnNormalLarge').length
  #       robot.send {room: "C51N74CLS"}, "#{title}は遅れてないよ。"
  #     else
  #       info = $('.trouble p').text()
  #       robot.send {room: "C51N74CLS"}, "#{title}は遅れているみたい。\n#{info}"
