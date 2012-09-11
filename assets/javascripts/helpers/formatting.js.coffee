_.extend StatusPro.Helpers,
  formatTime: (time_or_int) ->
    now = moment()
    time = moment.unix(time_or_int)

    formatted_time = if time.format('YYYY-MM-DD') == now.format('YYYY-MM-DD')
      time.format('HH:mm') # time only
    else
      time.format('ddd MMM Do, YYYY') # date and time

    "#{formatted_time} (#{time.fromNow()})"

  rawTime: (time_or_int) ->
    moment.unix(time_or_int).format()
