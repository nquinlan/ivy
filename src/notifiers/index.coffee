uuid = require 'node-uuid'

{MemoryNotifier} = require './memory'

# # Interface to Notifications
class NotificationManager
  NOTIFIER_TYPES =
    memory: MemoryNotifier


  constructor: ->
    @changeNotifier 'memory'

  changeNotifier: (name, options={}) ->
    if not NOTIFIER_TYPES[name]
      throw new Error "Queue #{name} not available."

    @notifier = new NOTIFIER_TYPES[name] options

  ###
  # Proxy attributes follow
  ###

  ###
  # Producer
  ###

  # Subscribe to completion of the event. Returns ID of the message.
  subscribe: (options) ->
    {messageSuffix} = options
    messageSuffix  ?= ''

    eventId = "#{uuid.v4()}-#{messageSuffix}"


    @notifier.subscribeToEvent


  ###
  # Consumer
  ###

  notify: ->
    @notifier.listen.apply @notifier, arguments


notifications = new NotificationManager()

module.exports = {
  notifications
}
