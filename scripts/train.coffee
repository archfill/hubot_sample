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
    else if target == 'm.yang'
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
      msg.send "train コマンドのヘルプ\r\n
使用法: train [オプション]\r\n\r\n
オプション\r\n
all：yahoo路線情報の運行情報　中部を表示\r\n
ユーザ名：入力されたユーザ名に該当する運行情報を表示\r\n\r\n
          tk\r\n
          t.ando\r\n
          m.yang\r\n
          a.nagura\r\n
          y.hieda\r\n\r\n
higashiyama：東山線\r\n
meijo：名城線\r\n
tsurumai：鶴舞線\r\n
sakuradori：桜通線\r\n
inuyama：犬山線\r\n
shibus：市バス"
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
        return msg.send "バス情報取得に失敗しました。"

      # BOMに気を付けること
      data = JSON.parse(body.replace(/^\uFEFF/, ''))
      # robot.logger.info data
      # for obj in data
      for obj in data
        if obj.rosen_id == "B_LINE"
          msg.send "#{obj.traffic_message}")

  new cronJob('0 30 7 * * 1-5', () ->
    searchTrainCron(nagoya_higashiyama)
    searchTrainCron(nagoya_meijo)
    searchTrainCron(nagoya_turumai)
    searchTrainCron(nagoya_sakuradori)
    searchTrainCron(nagoya_kamiiida)
    searchTrainCron(nagoya_meikou)
    searchTrainCron(meitetsu_inuyama)
    searchBusCron()
  null,
  true,
  "Asia/Tokyo"
  ).start()

  searchTrainCron = (url) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        robot.send {room: "C51N74CLS"}, "#{title}は遅れてないよ。"
      else
        info = $('.trouble p').text()
        robot.send {room: "C51N74CLS"}, "#{title}は遅れているみたい。\n#{info}"

  searchBusCron = () ->
    request.get("https://www.kotsu.city.nagoya.jp/jp/datas/latest_traffic.json?_#{new Date().getTime()}", (error, response, body) ->
      if error or response.statusCode != 200
        return msg.send "バス情報取得に失敗しました。"

      # BOMに気を付けること
      data = JSON.parse(body.replace(/^\uFEFF/, ''))
      # robot.logger.info data
      # for obj in data
      for obj in data
        if obj.rosen_id == "B_LINE"
          robot.send {room: "C51N74CLS"}, "市バス：#{obj.traffic_message}"
