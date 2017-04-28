# Description:
#   電車遅延情報をSlackに投稿する
#
# Commands:
#   hubot train < kaoru | yuri | all > - Return train info
#
# Author:
#   Kaoru Hotate

cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob

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

module.exports = (robot) ->

  searchAllTrain = (msg) ->
    # send HTTP request
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

  robot.respond /train (.+)/i, (msg) ->
    target = msg.match[1]

    if target == "all"
      searchAllTrain(msg)
    else if target == 'a.nagura'
      msg.send "登録してないよ。"
    else if target == 'y.yang'
      msg.send "登録してないよ。"
    else if target == 't.ando'
      msg.send "登録してないよ。"
    else if target == 'tk'
      msg.send "登録してないよ。"
    else if target == 'y.hieda'
      searchTrain(nagoya_turumai, msg)
      searchTrain(nagoya_higashiyama, msg)
    else if target == 'help'
      msg.send "train コマンドのヘルプ\r\n
使用法: train [オプション]\r\n\r\n
オプション\r\n
all：yahoo路線情報の運行情報　中部を表示\r\n
ユーザ名：入力されたユーザ名に該当する運行情報を表示\r\n\r\n
          tk\r\n
          t.ando\r\n
          y.yang\r\n
          a.nagura\r\n
          y.hieda"
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

  new cronJob('0 0 8 * * 1-5', () ->
    searchTrainCron(nagoya_higashiyama)
    searchTrainCron(nagoya_meijo)
    searchTrainCron(nagoya_turumai)
    searchTrainCron(nagoya_sakuradori)
    searchTrainCron(nagoya_kamiiida)
    searchTrainCron(nagoya_meikou)

  null,
  true,
  "Asia/Tokyo"
  ).start()

  new cronJob('0 35 13 * * 1-5', () ->
    searchTrainCron(nagoya_higashiyama)
    searchTrainCron(nagoya_meijo)
    searchTrainCron(nagoya_turumai)
    searchTrainCron(nagoya_sakuradori)
    searchTrainCron(nagoya_kamiiida)
    searchTrainCron(nagoya_meikou)

  null,
  true,
  "Asia/Tokyo"
  ).start()

  searchTrainCron = (url) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        robot.send {room: "#notifications"}, "#{title}は遅れてないよ。 "
      else
        info = $('.trouble p').text()
        robot.send {room: "#notifications"}, "#{title}は遅れているみたい。\n#{info}"
