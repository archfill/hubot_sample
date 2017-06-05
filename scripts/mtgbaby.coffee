cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob
request = require('request')
#Requiring the Mongodb package
mongo = require 'mongodb'
#Creating a MongoClient object
MongoClient = mongo.MongoClient
#Preparing the URL
url = 'mongodb://heroku_ztml25kt:H34jt7fh@ds155191.mlab.com:55191/heroku_ztml25kt'

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
      #mtgMessage(msg)
      #otameshi()
      #Connecting to the server
      console.log "#{url}"
      MongoClient.connect url, (err, db) ->

        if err
          console.log 'Unable to connect . Error:', err
        else
          console.log 'Connection established to', url
          #Close connection
          db.close()
        return
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

  otameshi = () ->
    mongodb_create_collection('test')

  mongodb_select = (collection_name,param) ->
    #Connecting to the server
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url
        #Creating collection object
        col = db.collection("#{collection_name}")
        #Inserting Documents
        #col.find({name: 'Ram'}).toArray (err, result)->
        col.find({"#{param}"}).toArray (err, result)->
        if err
          console.log err
        else
          console.log 'Found:', result
        #Close connection
        db.close()

  mongodb_select_all = (collection_name) ->
    #Connecting to the server
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url
        #Creating collection object
        col = db.collection("#{collection_name}")
        #Inserting Documents
        col.find().toArray (err, result)->
        if err
          console.log err
        else
          console.log 'Found:', result
        #Close connection
        db.close()

  mongodb_insert  = (collection_name,doc) ->
    #Connecting to the server
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url
      #Creating collection
      col = db.collection("#{collection_name}")

      #Inserting documents
      col.insert [doc], (err, result) ->
        if err
          console.log err
        else
          console.log "Documents inserted successfully"
        #Close connection
        db.close()
        return
      return

  mongodb_update = (collection_name,key,value) ->
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url
    	#Creating collection
        col = db.collection("#{collection_name}")
        #Reading Data
        #col.update {name:'Ram'},{$set:{city:'Delhi'}},(err, result)->
        col.update {"#{key}"},{$set:{"#{value}"}},(err, result)->
          if err
            console.log err
          else
          console.log "Document updated"

          #Closing connection
          db.close()
    	  return
      return

  mongodb_delete = (collection_name) ->
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url
    	#Creating collection
        col = db.collection("#{collection_name}")
        #Deleting Data
        col.remove()
        console.log "Document deleted"

        #Closing connection
        db.close()
      return

  mongodb_create_collection = (collection_name) ->
    #Connecting to the server
    MongoClient.connect url, (err, db) ->
      if err
        console.log 'Unable to connect . Error:', err
      else
        console.log 'Connection established to', url

        #Create collection
        col = db.collection("#{collection_name}")
        console.log "Collection created successfully."

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
