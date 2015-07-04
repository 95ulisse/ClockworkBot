telegram = require './telegramApi'
clockwork = require './clockworkApi'
log = require './log'
User = require '../models/user'

# Validation functions
isValidSender = (x) -> !!x.match /^(\d{1,12}|\w{1,11})$/i

# Table with the command handlers
handlers = [

    [ /^\/help$/i, (m, u) ->
        return telegram 'sendMessage', chat_id: m.from.id, disable_web_page_preview: true, text: """
            Hi #{u.name}, I'm ClockworkBot, your personal Telegram bot for Clockwork SMS.

            First of all, you need to register to http://www.clockworksms.com to obtain an API key.

            This is a list of all the possible commands:
            - /setapikey: Sets the Clockwork API Key to use to send messages. Pass "null" to delete the key.
            - /setdefaultfrom <number>: Sets a default sender number to use when not specified in the /sms command. Pass "null" to delete the default sender.
            - /sms from <senderNumber> to <destNumber> <message>: Sends an SMS to <destNumber> from <senderNumber>.
            - /sms <destNumber> <message>: Sends an SMS to <destNumber> from the default sender set with /setdefaultfrom.
            - /credit: Check the how much credit is left on your Clockwork account.
            - /help: Shows this help text.
            """
    ],

    [ /^\/setapikey\s+(null|[a-f0-9]+)$/i, (m, u, key) ->
        u.apiKey = if key is 'null' then null else key
        return u.save().then () ->
            log.info 'Updated API Key for user #' + u._id
            return telegram 'sendMessage', chat_id: m.from.id, text: 'API Key updated.'
    ],

    [ /^\/setdefaultfrom\s+(null|\w+)$/i, (m, u, from) ->
        if from != 'null' and not isValidSender from
            return telegram 'sendMessage', chat_id: m.from.id, text: 'Invalid sender. Please use a maximum of 12 digit (with international prefix, without "+" or leading zeros) or 11 characters.'
        u.defaultFrom = if from is 'null' then null else from
        return u.save().then () ->
            log.debug 'Updated default sender for user #' + u._id
            return telegram 'sendMessage', chat_id: m.from.id, text: 'Default sender updated.'
    ],

    [ /^\/credit$/i, (m, u) ->
        if not u.apiKey
            return telegram 'sendMessage', chat_id: m.from.id, text: 'Before knowing your balace, you have to set an API Key with /setapikey.'
        return clockwork.getBalance(u.apiKey).then (balance) ->
            if balance.ErrNo and balance.ErrDesc
                return telegram 'sendMessage', chat_id: m.from.id, text: "Error #{balance.ErrNo}: #{balance.ErrDesc}."
            else
                return telegram 'sendMessage', chat_id: m.from.id, text: 'Your credit is: ' + balance.Balance + balance.Currency.Symbol
    ],

    [ /^\/sms\s+(?:from\s+(\w+)\s+to\s+)?([0-9]+)\s+([\w\W]+)$/i, (m, u, from, to, contents) ->
        if not u.apiKey
            return telegram 'sendMessage', chat_id: m.from.id, text: 'Before sending messages you have to set an API Key with /setapikey.'
        if from and not isValidSender from
            return telegram 'sendMessage', chat_id: m.from.id, text: 'Invalid sender. Please use a maximum of 12 digit (with international prefix, without "+" or leading zeros) or 11 characters.'
        from = u.defaultFrom if not from
        if not from
            return telegram 'sendMessage', chat_id: m.from.id, text: 'No default sender configured. Please, configure a default sender with /setdefaultfrom or specify the sender explicitly with the syntax /sms from <sender> to <destination> <message>.'
        return clockwork.sendSms(u.apiKey, from, to, contents).then (res) ->
            if res.ErrNo and res.ErrDesc
                return telegram 'sendMessage', chat_id: m.from.id, text: "Error #{res.ErrNo}: #{res.ErrDesc}."
            else
                log.info "User #{u._id} sent message from #{from} to #{to}."
                return telegram 'sendMessage', chat_id: m.from.id, text: 'Message sent.'
    ]

]

module.exports = (m) ->

    # We understand only text messages, so discard everything that isn't simple text
    return if not m.text or m.text[0] != '/'

    # First of all, look for the user who sent the command in the database
    User.find(_id: m.from.id).then (u) ->
        return if not u or u.length is 0 then new User(_id: m.from.id, name: m.from.first_name).save() else u[0]

    # Then, delegate the command to the correct handler
    .then (u) ->
        for h in handlers
            match = m.text.match h[0]
            if match
                match.shift()
                return h[1].apply null, [ m, u ].concat match

        telegram 'sendMessage', chat_id: m.from.id, text: 'Sorry, I didn\'t understand. Type /help to see a list of the commands I understand.'

    .then null, (e) ->
        log.error if e.stack then e.stack else e
        telegram 'sendMessage', chat_id: m.from.id, text: 'An unexpected error has occured. We are sorry for the inconvenience.'
