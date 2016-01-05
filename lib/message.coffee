class Message

  api = null

  id = null
  author = {}
  date = null

  attributes = null

  event = null

  constructor: (_attributes, _api, _event)->

    api = _api

    attributes = _attributes

    id = _attributes.message_id
    author = _attributes.from

    event = _event

  authorIsMe: ->
    api.getMe().id is author.id

module.exports = Message