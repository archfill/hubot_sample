cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob
request = require('request')

# heroku_config = messages: JSON.parse(process.env.HUBOT_USER_CONFIG ? '[]')

# 会話回数
mtg_respond_count = ['y.hieda':['6']]
mtg_request_save = {}

module.exports = (robot) ->

  # 全体
  robot.hear /mtg (.+)/i, (msg) ->
    room = msg.message.user.room

    # チャンネル指定
    # hiedabottest
    # notifications
    if room == "C55RDV935" or room == "C51N74CLS"
      mtgMain(msg)

 # 個人宛
  # robot.respond /mtg (.+)/i, (msg) ->
  #   mtgMain(msg)

  robot.respond /(.+)/i, (msg) ->
    mtgMessage(msg)

  mtgMain = (msg) ->
    target = msg.match[1]

    if target == "all"
      msg.send "not all..."
    else if target == 'start'
      mtgMessage(msg)
    else
      msg.send "#{target}はわかりません。(´･ω ･`)"

  mtgMessage = (msg) ->
    user = msg.message.user.name
    edit_array = []
    for key,val of mtg_request_save
      if user == key
        edit_array = val

    edit_array.push(msg.match[1])

    mtg_request_save[user] = edit_array

    for key,val of mtg_request_save
      msg.send "#{key} #{val}"
    # for val,i in mtg_respond_count
    #   msg.send "#{i} #{val}"

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
