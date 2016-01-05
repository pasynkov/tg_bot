class Chat

  chatId = null
  first_name = ""
  last_name = ""
  username = ""
  type = ""

  api = null

  constructor: (params, _api)->

    api = _api

    chatId = params.id
    first_name = params.first_name
    last_name = params.last_name
    username = params.username
    type = params.type

  send: ([text, options] ..., callback)=>

    options ?= {}

    api.sendMessage(chatId, text, options)
    .then(
      (r)=>
        console.log r
        callback()
      callback
    )


module.exports = Chat