NodeTelegramBotApi = require "node-telegram-bot-api"
_ = require "underscore"

Chat = require "./chat"
Message = require "./message"

class TelegramBot

  api = null
  connected = false
  me = false

  Chat: Chat
  Message: Message

  constructor: (token)->

    api = new NodeTelegramBotApi token, {polling: true}

  connect: (callback)=>

    api.getMe().then(
      ({id, first_name, username})=>

        connected = true

        me = {id, first_name, username}

        callback()
      callback
    )

  isConnected: ->
    connected is true

  getMe: ->
    me

  subscribe: (eventsToSubscribe, listener, callback = false)=>

    if _.isFunction(eventsToSubscribe)
      listener = eventsToSubscribe
      eventsToSubscribe = "*"

    if _.isArray eventsToSubscribe
      events = _.filter eventsToSubscribe, (e)-> e in api.messageTypes
    else if eventsToSubscribe in api.messageTypes
        events = [eventsToSubscribe]
      else if eventsToSubscribe is "*"
        events = api.messageTypes
      else
        events = []

    unless events.length
      error = "Events `#{JSON.stringify eventsToSubscribe}` not found"
      if _.isFunction(callback)
        return callback error
      else
        throw new Error error

    for event in events
      api.on event, @createMessageCallback(event, listener)

    if _.isFunction(callback)
      callback()
    else return @


  createMessageCallback: (event, listener)->
    (params)->
      listener(
        new Message params, api
        new Chat params.chat, api, event
        event
      )








        

module.exports = TelegramBot