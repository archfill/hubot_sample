cronJob = require('cron').CronJob

module.exports = (robot) ->

  new cronJob('0 5 12 * * 5', () ->
    cron_send_message()
  null,
  true,
  "Asia/Tokyo"
  ).start()

  cron_send_message = () ->
    robot.send {room: "C55RDV935"}, "てｓｔ"
