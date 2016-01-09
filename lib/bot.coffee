NodeTelegramBotApi = require "node-telegram-bot-api"
_ = require "underscore"
async = require "async"
request = require "request"

Chat = require "./chat"
Message = require "./message"

COMMAND_EVENT = "command"

EventEmitter = require "events"

class TelegramBot extends EventEmitter

  constructor: (token, @CustomChatClass, @CustomMessageClass)->

    super

    @api = new NodeTelegramBotApi token

    @api.processUpdate = @processUpdate

    @regExpCallbacks = []

    @connected = false

    @me = false

  Chat: @Chat = Chat

  Message: @Message = Message

  connect: (callback)=>

    @api.initPolling()

    @api.getMe().then(
      ({id, first_name, username})=>

        @connected = true

        @me = {id, first_name, username}

        callback()
      callback
    )

  isConnected: =>
    @connected is true

  getCredentials: =>
    @me

  processUpdate: (update = {})=>

    if (attributes = update.message)

      MessageClass = @getMessageClass()
      ChatClass = @getChatClass()

      chat = new ChatClass attributes.chat, @
      message = new MessageClass attributes, @, chat

      async.parallel(
        [
          chat.initialize
          message.initialize
        ]
        =>
          event = message.getEvent()

          @emit "*", message, chat
          @emit event, message, chat

          if message.isCommand()
            @emit "command:#{message.getCommandName()}", message, chat, message.getCommandArguments()

          if message.isText()
            for item in @regExpCallbacks
              if item.regExp.exec message.getText()
                if item.eventName
                  @emit item.eventName, message, chat
                else
                  item.callback message, chat

      )

  getMessageTypes: =>

    @api.messageTypes

  onText: (regExp, callback)=>
    unless regExp instanceof RegExp
      regExp = new RegExp regExp

    if _.isFunction(callback)
      eventName = false
    else
      eventName = callback
      callback = false

    @regExpCallbacks.push {
      regExp
      eventName
      callback
    }


  getMessageClass: =>

    @CustomMessageClass or Message

  getChatClass: =>

    @CustomChatClass or Chat

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

    @api[methodName].apply(@api, params)
    .then(
      ->
        args = _.flatten [null, _.toArray(arguments)]
        callback.apply null, args
      callback
    )


module.exports = TelegramBot