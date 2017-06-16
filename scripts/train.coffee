cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob
request = require('request')

# 名古屋市交通局　運行情報
nagoya_koutsukyoku = 'http://www.kotsu.city.nagoya.jp/jp/pc/emergency/index.html'

# 名古屋市営東山線
nagoya_higashiyama = 'https://transit.yahoo.co.jp/traininfo/detail/240/0/'
# 名古屋市営名城線
nagoya_meijo = 'https://transit.yahoo.co.jp/traininfo/detail/241/0/'
# 名古屋市営鶴舞線
nagoya_turumai = 'https://transit.yahoo.co.jp/traininfo/detail/242/0/'
# 名古屋市営桜通線
nagoya_sakuradori = 'https://transit.yahoo.co.jp/traininfo/detail/243/0/'
# 名古屋市営上飯田線
nagoya_kamiiida = 'https://transit.yahoo.co.jp/traininfo/detail/400/0/'
# 名古屋市営名港線
nagoya_meikou = 'https://transit.yahoo.co.jp/traininfo/detail/405/0/'
# 名鉄犬山線
meitetsu_inuyama = 'https://transit.yahoo.co.jp/traininfo/detail/220/0/'

module.exports = (robot) ->

  searchAllTrain = (msg) ->
    # send HTTP request
    # 運行情報 中部
    baseUrl = 'https://transit.yahoo.co.jp/traininfo/area/5/'
    cheerio.fetch baseUrl, (err, $, res) ->
      if $('.elmTblLstLine.trouble').find('a').length == 0
        msg.send "事故や遅延情報はありません"
        return
      $('.elmTblLstLine.trouble a').each ->
        url = $(this).attr('href')
        cheerio.fetch url, (err, $, res) ->
          title = "◎ #{$('h1').text()} #{$('.subText').text()}"
          result = ""
          $('.trouble').each ->
            trouble = $(this).text().trim()
            result += "- " + trouble + "\r\n"
          msg.send "#{title}\r\n#{result}"

  # 全体
  robot.hear /train (.+)/i, (msg) ->
    room = msg.message.user.room

    # チャンネル指定
    # hiedabottest
    # notifications
    if room == "C55RDV935" or room == "C51N74CLS"
      fields = []
      searchTrainCron(nagoya_higashiyama,fields)
      #searchMain(msg)

 # 個人宛
  robot.respond /train (.+)/i, (msg) ->
    searchMain(msg)

  searchMain = (msg) ->
    target = msg.match[1]

    if target == "all"
      searchAllTrain(msg)
    else if target == 'a.nagura'
      msg.send "登録してないよ。"
    else if target == 't.ando'
      searchTrain(nagoya_turumai, msg)
      searchTrain(meitetsu_inuyama, msg)
    else if target == 'tk'
      searchBus(nagoya_koutsukyoku, msg)
    else if target == 'y.hieda'
      searchTrain(nagoya_turumai, msg)
      searchTrain(nagoya_higashiyama, msg)

    else if target == 'shibus'
      searchBus(nagoya_koutsukyoku, msg)

    else if target == 'higashiyama'
      searchTrain(nagoya_higashiyama, msg)
    else if target == 'meijo'
      searchTrain(nagoya_meijo, msg)
    else if target == 'tsurumai'
      searchTrain(nagoya_turumai, msg)
    else if target == 'sakuradori'
      searchTrain(nagoya_sakuradori, msg)
    else if target == 'inuyama'
      searchTrain(meitetsu_inuyama, msg)

    else if target == 'help'
      msg.send "train コマンドのヘルプ\n" +
                "使用法: train [オプション]\n\n" +
                "オプション\n" +
                "all：yahoo路線情報の運行情報　中部を表示\n" +
                "ユーザ名：入力されたユーザ名に該当する運行情報を表示\n\n" +
                "          tk\n" +
                "          t.ando\n" +
                "          a.nagura\n" +
                "          y.hieda\n\n" +
                "higashiyama：東山線\n" +
                "meijo：名城線\n" +
                "tsurumai：鶴舞線\n" +
                "sakuradori：桜通線\n" +
                "inuyama：犬山線\n" +
                "shibus：市バス"
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

  searchBus = (url, msg) ->
    # バス専用処理
    # スクレイピングでは取得できないため
    request.get("https://www.kotsu.city.nagoya.jp/jp/datas/latest_traffic.json?_#{new Date().getTime()}", (error, response, body) ->
      if error or response.statusCode != 200
        return msg.send "市バスの情報取得に失敗しました。"

      # BOMに気を付けること
      data = JSON.parse(body.replace(/^\uFEFF/, ''))
      # robot.logger.info data
      # for obj in data
      for obj in data
        if obj.rosen_id == "B_LINE"
          msg.send "市バス：#{obj.traffic_message}"
    )

  new cronJob('0 30 7 * * 1-5', () ->
    fields = []
    searchTrainCron(nagoya_higashiyama,fields)
    searchTrainCron(nagoya_meijo,fields)
    searchTrainCron(nagoya_turumai,fields)
    searchTrainCron(nagoya_sakuradori,fields)
    searchTrainCron(nagoya_kamiiida,fields)
    searchTrainCron(nagoya_meikou,fields)
    searchTrainCron(meitetsu_inuyama,fields)
    searchBusCron(fields)
    if fields.length
      sendMsgAttachments("C51N74CLS",fields)
  null,
  true,
  "Asia/Tokyo"
  ).start()

  new cronJob('0 20 15 * * 1-5', () ->
    fields = []
    searchTrainCron(nagoya_higashiyama,fields)
    searchTrainCron(nagoya_meijo,fields)
    searchTrainCron(nagoya_turumai,fields)
    searchTrainCron(nagoya_sakuradori,fields)
    searchTrainCron(nagoya_kamiiida,fields)
    searchTrainCron(nagoya_meikou,fields)
    searchTrainCron(meitetsu_inuyama,fields)
    searchBusCron(fields)
    robot.send {room: "C55RDV935"}, "#{fields}"
    if fields.length > 0
      sendMsgAttachments("C55RDV935",fields)
  null,
  true,
  "Asia/Tokyo"
  ).start()

  searchTrainCron = (url,fields) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        #遅れてなければ通知しない
        #robot.send {room: "C51N74CLS"}, "#{title}は遅れてないよ。"

        field = {}
        field['title'] = "#{title}"
        field['value'] = "遅れてないよ。"
        field['short'] = false
        console.log field
        fields.push(field)
      else
        #info = $('.trouble p').text()
        #robot.send {room: "C51N74CLS"}, "#{title}は遅れているみたい。\n#{info}"

        field = {}
        field['title'] = "#{title}"
        field['value'] = "#{info}"
        field['short'] = false
        fields.push(field)

  searchBusCron = (fields) ->
    request.get("https://www.kotsu.city.nagoya.jp/jp/datas/latest_traffic.json?_#{new Date().getTime()}", (error, response, body) ->
      if error or response.statusCode != 200
        return robot.send "市バスの情報取得に失敗しました。"

      # BOMに気を付けること
      data = JSON.parse(body.replace(/^\uFEFF/, ''))
      # robot.logger.info data
      # for obj in data
      for obj in data
        if obj.rosen_id == "B_LINE"
          if obj.traffic_message == "平常通り運行しています。"
            #遅れていないので通知しない
            #robot.send {room: "C51N74CLS"}, "市バス：#{obj.traffic_message}"
            field = {}
            field['title'] = "市バス"
            field['value'] = "#{obj.traffic_message}"
            field['short'] = false
            fields.push(field)
          else
            #robot.send {room: "C51N74CLS"}, "市バス：#{obj.traffic_message}"

            field = {}
            field['title'] = "市バス"
            field['value'] = "#{obj.traffic_message}"
            field['short'] = false
            fields.push(field)
    )

  sendMsgAttachments = (room, fields) ->
    # おそらく当日日付を取得
    timestamp = new Date/1000|0

    # https://api.slack.com/docs/message-attachments
    attachments = [
      {
        color: 'good',
        fields: [fields]
      }
    ]

    options = { as_user: true, link_names: 1, attachments: attachments }

    client = robot.adapter.client
    client.web.chat.postMessage(room, '', options)

