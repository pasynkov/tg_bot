
async = require "async"
_ = require "underscore"

Message = require "./message"

CHAT_ACTIONS = [
  "typing", "upload_photo", "record_video", "upload_video", "record_audio", "upload_audio", "upload_document", "find_location"
]

class ReplyMarkup

  toOptions: => @params

class Keyboard extends ReplyMarkup

  constructor: (oneTime = false, selective = false, resize = false)->

    @params = {
      resize_keyboard: resize
      one_time_keyboard: oneTime
      selective: selective
      keyboard: []
    }

  addRow: (buttons)=>

    @params.keyboard.push _.flatten buttons

    return @

  setRows: (rows)=>

    for row in rows
      @addRow row

    return @

  setButtons: (buttons)=>
    @setRows buttons



class ForceReply extends ReplyMarkup

  constructor: (selective = false)->

    @params = {
      force_reply: true
      selective: selective
    }

class HideKeyboard extends ReplyMarkup

  constructor: (selective = false)->

    @params = {
      selective
      hide_keyboard: true
    }

class MessageOptions

  constructor: ->

    @params = {}

  markdown: =>

    @params.parse_mode = "Markdown"

  disablePagePreview: =>

    @params.disable_web_page_preview = true

  reply: (messageId)=>

    @params.reply_to_message_id = messageId

  toOptions: => @params



class Chat

  chatId = null
  first_name = ""
  last_name = ""
  username = ""
  type = ""

  api = null

  replyMarkup = null

  messageOptions = null

  constructor: (params, _api)->

    @_api = api = _api

    chatId = params.id
    first_name = params.first_name
    last_name = params.last_name
    username = params.username
    type = params.type

  initialize: (callback)->
    callback()

  sendMessage: ([text, options] ..., callback)=>

    options = @prepareOptions options

    api.sendMessage chatId, text, options, (err, attributes)->

      return callback err if err

      callback null, new Message(attributes, api, "outcoming")

  prepareOptions: (options = {})=>

    if messageOptions
      options = messageOptions.toOptions()

    if replyMarkup
      options.reply_markup = replyMarkup.toOptions()

    options


  sendAction: (action, callback)->

    if action not in CHAT_ACTIONS
      return callback "Not not available chatAction `#{action}`"

    api.sendChatAction chatId, action, callback

  getId: ->

    chatId

  sendMarkdown: =>
    @setupOptions()

    messageOptions.markdown()

    @

  disablePagePreview: =>
    @setupOptions()

    messageOptions.markdown()

    @

  replyTo: (message)=>

    messageId = false

    if message instanceof api.getMessageClass()
      messageId = message.getId()
    else
      unless _.isNaN(+message)
        messageId = +message

    if messageId
      @setupOptions()
      messageOptions.reply messageId

    @


  setupOptions: ->

    messageOptions ?= new MessageOptions

  createHideKeyboard: (selective)->

    replyMarkup = new HideKeyboard selective

    replyMarkup

  createForceReply: (selective)->

    replyMarkup = new ForceReply selective

    replyMarkup

  createKeyboard: (oneTime, selective, resize)->

    replyMarkup = new Keyboard oneTime, selective, resize

    replyMarkup

  removeReplyMarkup: ->

    replyMarkup = null





module.exports = Chat