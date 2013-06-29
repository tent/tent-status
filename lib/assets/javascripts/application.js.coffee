#= require ./tent_status

TentStatus.once 'config:ready', -> TentStatus.run()
