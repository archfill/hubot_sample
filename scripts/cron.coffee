cronJob = require('cron').CronJob

module.exports = (robot) ->

  new cronJob('0 0 9 * * 5', () ->
    #hiedatest C55RDV935
    #product_thai_cm C5DCNLG3E
    #open_hieda C5BT4BJSU
    # cron_send_message("C55RDV935","test")
    cron_send_message("C55RDV935","y.hieda さん予定がありますよ。\r\n
■タイCM　定例会\r\n
　13:00～14:00 @NIC MR3")
  null,
  true,
  "Asia/Tokyo"
  ).start()

  cron_send_message = (roomid,message) ->
    robot.send {room: "#{roomid}"}, "#{message}"
