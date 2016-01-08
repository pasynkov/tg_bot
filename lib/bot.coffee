NodeTelegramBotApi = require "node-telegram-bot-api"
_ = require "underscore"
async = require "async"
request = require "request"

Chat = require "./chat"
Message = require "./message"

COMMAND_EVENT = "command"

class TelegramBot

  api = null
  connected = false
  me = false

  CustomChat = null
  CustomMessage = null

  constructor: (token, CustomChatClass, CustomMessageClass)->

    api = new NodeTelegramBotApi token, {polling: true}

    CustomChat = CustomChatClass
    CustomMessage = CustomMessageClass

  Chat: @Chat = Chat
  Message: @Message = Message

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

  getCredentials: ->
    me

  #todo доработать основательно. добавить плюхи типа command:start и тд
  subscribe: (eventsToSubscribe, listener, callback = false)=>

    if _.isFunction(eventsToSubscribe)
      listener = eventsToSubscribe
      eventsToSubscribe = "*"

    regExps = []

    subscribeToCommands = false

    if _.isArray eventsToSubscribe
      events = _.filter(
        eventsToSubscribe
        (e)->
          if e is COMMAND_EVENT
            subscribeToCommands = true
          if e instanceof RegExp
            regExps.push e
            return false
          else
            return e in api.messageTypes
      )
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
      api.on event, @getMessageCallback(event, listener)

    for regExp in regExps
      api.onText regExp, @getMessageCallback(event, listener)

    if _.isFunction(callback)
      callback()
    else return @


  getMessageCallback: (event, listener)=>
    (params)=>

      MessageClass = @getMessageClass()
      ChatClass = @getChatClass()

      chat = new ChatClass params.chat, @, event
      message = new MessageClass params, @, event, chat

      async.parallel(
        [
          chat.initialize
          message.initialize
        ]
        ->
          listener message, chat, event
      )

  getMessageClass: ->

    CustomMessage or Message

  getChatClass: ->

    CustomChat or Chat

  getFileBuffer: (fileId, callback)->

    async.waterfall(
      [
        async.constant fileId
        @getFileLink
        request.get
      ]
      (err, res, body)->
        callback err, body
    )


  sendMessage: ([chatId, text, options] ..., callback)=>
    @invokeApiMethod "sendMessage", chatId, text, options, callback

  sendChatAction: ([chatId, action] ..., callback)=>
    @invokeApiMethod "sendChatAction", chatId, action, callback

  getFile: (fileId, callback)=>
    @invokeApiMethod "getFile", fileId, callback

  getFileLink: (fileId, callback)=>
    @invokeApiMethod "getFileLink", fileId, callback

  downloadFile: (fileId, destination, callback)=>
    @invokeApiMethod "downloadFile", fileId, destination, callback

  invokeApiMethod: ([methodName, params ...] ..., callback)=>

    api[methodName].apply(api, params)
    .then(
      ->
        args = _.flatten [null, _.toArray(arguments)]
        callback.apply null, args
      callback
    )


module.exports = TelegramBot