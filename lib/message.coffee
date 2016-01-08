_ = require "underscore"

COMMAND_EVENT = "command"
TEXT_EVENT = "text"
DOCUMENT_EVENT = "document"
PHOTO_EVENT = "photo"

REPLY_FIELD = "reply_to_message"

COMMAND_REGEXP = new RegExp "^/([a-zA-Z0-9_]+)\s*", "i"

class Message

  api = null

  id = null
  author = {}
  date = null

  attributes = null

  event = null

  chat = null

  isCommand = null

  question = null

  constructor: (_attributes, _api, _event, _chat)->

    api = _api

    attributes = _attributes

    id = _attributes.message_id
    author = _attributes.from

    date = new Date _attributes.date

    event = _event

    chat = _chat

  initialize: (callback)->
    callback()

  getId: ->

    id

  isOwnMessage: =>

    @getBotId() is author.id

  getBotId: =>

    botCredentials = @getBotCredentials()

    botCredentials.id

  getBotCredentials: ->

    api.getCredentials()

  getEvent: =>

    if @isCommand()
      COMMAND_EVENT
    else event

  isReply: ->

    _.has attributes, REPLY_FIELD

  getQuestion: =>

    if @isReply()

      question ?= new Message attributes[REPLY_FIELD], api, "question"

      question

    else false

  isCommand: =>

    isCommand ?= event is TEXT_EVENT and @hasCommandMark()

    isCommand

  hasCommandMark: =>

    COMMAND_REGEXP.test @getText()

  getText: ->

    attributes.text or attributes.caption

  getCommandName: =>

    if @isCommand()
      @getText().match(COMMAND_REGEXP)[1]
    else false

  getCommandArguments: ->

    if @isCommand()

      argumentsString = @getText().replace(COMMAND_REGEXP, "").trim()

      if argumentsString

        _.map(argumentsString.split " ", (arg)-> arg.trim())

      else []

    else []

  hasFile: =>

    @getEvent() in [PHOTO_EVENT, DOCUMENT_EVENT]

  hasPhoto: =>

    if @hasFile()

      if @getEvent() is DOCUMENT_EVENT

        attributes.document.mime_type.split("/").shift() is "image"

      else true

    else false

  getFileBuffer: (callback)=>

    fileId = @getFileId()

    api.getFileBuffer fileId, callback

  downloadFileTo: (path, callback)=>

    fileId = @getFileId()

    api.downloadFile fileId, path, callback


  getFileId: ->

    if @getEvent() is DOCUMENT_EVENT

      @getDocumentId()

    else

      @getOriginalPhotoId()


  getDocumentId: ->

    attributes.document.file_id

  getOriginalPhotoId: =>

    @getOriginalPhotoAttributes().file_id

  getOriginalPhotoAttributes: ->

    _.last attributes.photo






module.exports = Message