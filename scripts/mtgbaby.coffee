cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob
request = require('request')
#Requiring the Mongodb package
mongo = require 'mongodb'
#Creating a MongoClient object
MongoClient = mongo.MongoClient
#Preparing the URL
url = 'mongodb://heroku_ztml25kt:fg0gu4tnl8r7i88p6p0epp7ge1@ds155191.mlab.com:55191/heroku_ztml25kt'

# heroku_config = messages: JSON.parse(process.env.HUBOT_USER_CONFIG ? '[]')

# 質問内容
mtg_message_list = ['今日の体調は？','今日の意気込みは？','今日のタスクは？忙しそう？','今日は社外への外出予定がある？','今日の帰宅予定は何時？','この後個別に上長に相談したいことある？']
# 会話回数
mtg_respond_count = {}
mtg_day = {}
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

    mongodb_connect()

    dateString = ""
    newDate = new Date()
    dateString += newDate.getFullYear() + '/'
    dateString += (newDate.getMonth() + 1) + '/'
    dateString += newDate.getDate()

    message_lengih = mtg_message_list.length
    user = msg.message.user.name
    edit_respond_count = 1
    mtg_message = ''
    edit_request_array = []
    mtg_user_date = ''

    for key,val of mtg_day
      if user == key
        mtg_user_date = val

    if dateString == mtg_user_date
      msg.send "今日のMTGは終わったよ。"
    else
      for key,val of mtg_respond_count
        if user == key
          edit_respond_count = val

      mtg_message = mtg_message_list[edit_respond_count-1]

      for key,val of mtg_request_save
        if user == key
          edit_request_array = val

      edit_request_array.push(msg.match[1])

      mtg_request_save[user] = edit_request_array

      for key,val of mtg_request_save
        msg.send "#{key} , #{mtg_message} , #{val}"

      edit_respond_count++
      if message_lengih < edit_respond_count
        mtgSendChannel()
        mtg_respond_count[user] = 1
        mtg_day[user] = dateString
      else
        mtg_respond_count[user] = edit_respond_count

  mtgSendChannel = () ->
    room_id = "C55RDV935"
    robot.send {room: "#{room_id}"}, "TEST"

  mongodb_connect = () ->
    #Connecting to the server
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url
        #Close connection
        db.close()
      return

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
