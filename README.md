# Simple Async-oriented Telegram Bot

Bot has simplify interface for fast creating telegram bots. Events, expect and other.

# Installation

```sh
npm install node-telegram-bot-api
```

# Integration

```js
var TelegramBot = require('tg_bot');
var bot = new TelegramBot('YOUR_TELEGRAM_BOT_TOKEN');

bot.on('*',function(message, chat){ //In all events callback receive objects [Message](#Message) and [Chat](#Chat)
    // your logic here ...
    
    chat.sendMessage("Hello!",function(error){
        console.error(error);
    });
    
})

```
<a name="API"></a>
#API
 
Telegram Bot builded on [node-telegram-bot-api](https://github.com/yagop/node-telegram-bot-api)

* [TelegramBot](#TelegramBot)
    * [new TelegramBot(token)](#tg_new_tg)
    * [telegramBot.connect(callback)](#tg_connect)
    * [telegramBot.isConnected()](#tg_isConnected)
    * [telegramBot.getCredentials()](#tg_getCredentials)
    * [telegramBot.onText(regExp, [callback or event name])](#tg_onText)
    * [telegramBot.Events](#events)
    * [telegramBot.Chat](#chat)
    * [telegramBot.Message](#message)
    
* [Chat](#chat)
    * [chat.initialize(callback)](#ch_initialize)
    * [chat.sendMessage(text [, options], callback)](#ch_sendMessage)
    * [chat.sendAction(action, callback)](#ch_sendAction)
    * [chat.getId()](#ch_getId)
    * [chat.getType()](#ch_getType)
    * [chat.sendMarkdown()](#ch_sendMarkdown)
    * [chat.disablePagePreview()](#ch_disablePagePreview)
    * [chat.replyTo(Message or messageId)](#ch_replyTo)
    * [chat.createHideKeyboard(selective)](#ch_createHideKeyboard)
    * [chat.createForceReply(selective)](#ch_createForceReply)
    * [chat.createKeyboard(oneTime, selective, resize)](#ch_createKeyboard)
    * [chat.removeReplyMarkup()](#ch_removeReplyMarkup)
    
* [Message](#message)
    * [message.initialize(callback)](#mg_initialize)
    * [message.getId()](#mg_getId)
    * [message.isOwnMessage()](#mg_isOwnMessage)
    * [message.getAuthorId()](#mg_getAuthorId)
    * [message.getEvent()](#mg_getEvent)
    * [message.isReply()](#mg_isReply)
    * [message.getQuestion()](#mg_getQuestion)
    * [message.setCommand()](#mg_setCommand)
    * [message.isCommand()](#mg_isCommand)
    * [message.isText()](#mg_isText)
    * [message.hasCommandMark()](#mg_hasCommandMark)
    * [message.getText()](#mg_getText)
    * [message.getCommandName()](#mg_getCommandName)
    * [message.getCommandArguments()](#mg_getCommandArguments)
    * [message.hasFile()](#mg_hasFile)
    * [message.hasPhoto()](#mg_hasPhoto)
    * [message.getFileBuffer()](#mg_getFileBuffer)
    * [message.downloadFileTo()](#mg_downloadFileTo)
    * [message.getFileId()](#mg_getFileId)
    * [message.getDocumentId()](#mg_getDocumentId)
    * [message.getOriginalPhotoId()](#mg_getOriginalPhotoId)
    * [message.getOriginalPhotoAttributes()](#mg_getOriginalPhotoAttributes)
    * [message.setExpectantIfExists(callback)](#mg_setExpectantIfExists)
    * [message.getExpectant(callback)](#mg_getExpectant)
    * [message.removeExpectant(callback)](#mg_removeExpectant)
    * [message.expectArgumentForCommand(command)](#mg_expectArgumentForCommand)
    * [message.cancelExpectation()](#mg_cancelExpectation)
        
    



<a name="TelegramBot">

<a name="Message"></a>





