_ = require "underscore"

COMMAND_EVENT = "command"
TEXT_EVENT = "text"
DOCUMENT_EVENT = "document"
PHOTO_EVENT = "photo"

REPLY_FIELD = "reply_to_message"

COMMAND_REGEXP = new RegExp "^/([a-zA-Z0-9_]+)\s*", "i"

class Message

  constructor: (@attributes, @api, @chat)->

    @id = @attributes.message_id
    @author = @attributes.from

    @date = new Date @attributes.date

    @event = @detectEvent()

    @_question = null

    @_isCommand = null

    @expectant = null


  initialize: (callback)->
    callback()

  detectEvent: =>

    event = null

    for messageType in @api.getMessageTypes()
      if @attributes[messageType]
        event = messageType

    event

  getId: =>

    @id

  isOwnMessage: =>

    @getBotId() is @getAuthorId()

  getBotId: =>

    botCredentials = @getBotCredentials()

    botCredentials.id

  getAuthorId: =>

    @author.id

  getBotCredentials: =>

    @api.getCredentials()

  getEvent: =>

    if @isCommand()
      COMMAND_EVENT
    else @event

  isReply: ->

    _.has @attributes, REPLY_FIELD

  getQuestion: =>

    if @isReply()

      @_question ?= new Message @attributes[REPLY_FIELD], @api, @chat

      @_question

    else false

  setCommand: (@expectant)=>

  isCommand: =>

    @_isCommand ||= if @expectant then true else @isText() and @hasCommandMark()

  isText: =>

    @event is TEXT_EVENT

  hasCommandMark: =>

    COMMAND_REGEXP.test @getText()

  getText: ->

    @attributes.text or @attributes.caption

  getCommandName: =>

    if @isCommand()
      @expectant or @getText().match(COMMAND_REGEXP)[1]
    else false

  getCommandArguments: =>

    if @isCommand()

      argumentsString = @getText().replace(COMMAND_REGEXP, "").trim()

      if argumentsString

        _.map(argumentsString.split(" "), (arg)-> arg.trim())

      else []

    else []

  hasFile: =>

    @getEvent() in [PHOTO_EVENT, DOCUMENT_EVENT]

  hasPhoto: =>

    if @hasFile()

      if @getEvent() is DOCUMENT_EVENT

        @attributes.document.mime_type.split("/").shift() is "image"

      else true

    else false

  getFileBuffer: (callback)=>

    fileId = @getFileId()

    @api.getFileBuffer fileId, callback

  downloadFileTo: (path, callback)=>

    fileId = @getFileId()

    @api.downloadFile fileId, path, callback


  getFileId: =>

    if @getEvent() is DOCUMENT_EVENT

      @getDocumentId()

    else

      @getOriginalPhotoId()


  getDocumentId: =>

    @attributes.document.file_id

  getOriginalPhotoId: =>

    @getOriginalPhotoAttributes().file_id

  getOriginalPhotoAttributes: =>

    _.last @attributes.photo

  setExpectantIfExists: (callback)=>

    return callback() if @isCommand()

    @getExpectant (err, expectant)=>

      if expectant
        @setCommand expectant.command

      @removeExpectant callback

  getExpectant: (callback)=>

    if (expectant = @api.expectants["#{@chat.getType()}:#{@chat.getId()}:#{@getAuthorId()}"])
      callback null, expectant
    else callback null, false

  removeExpectant: (callback)=>

    @cancelExpectation()

    callback()

  expectArgumentForCommand: (command)=>

    @chat.expectArgumentForCommand @getAuthorId(), command

  cancelExpectation: =>

    @chat.cancelExpectation @getAuthorId()




module.exports = Message