fs = require 'fs'
express = require 'express'
app = express()
bodyParser = require 'body-parser'
mongoose = require 'mongoose'
config = require './lib/config'
log = require './lib/log'
messageParser = require './lib/messageParser'

telegram = require './lib/telegramApi'

# Common middlewares
app.use bodyParser.json()

# Since Telegram might deliver out-of-order updates,
# we store all the non-sequential messages in memory
# to make sure that they are processed in the right order
updateQueue = do () ->
    lastId = -1
    queue = {}
    return (u) ->
        lastId = u.update_id - 1 if lastId == -1
        throw new Error('Duplicate update ID #' + u.update_id) if queue[u.update_id] or u.update_id <= lastId
        queue[u.update_id] = u
        log.debug 'Enqueued update #' + u.update_id

        u = queue[lastId + 1]
        while u
            messageParser u.message
            lastId++
            u = queue[lastId + 1]

# The one and only HTTP entry point
app.post '/', (req, res) ->
    if req.body and typeof req.body.update_id is 'number' and typeof req.body.message is 'object'
        updateQueue req.body
        res.sendStatus 200
    else
        log.warn 'Discarded invalid update', { update: req.body }
        res.sendStatus 500

# Reduce all the errors to 500
app.use (err, req, res, next) ->
    log.error err.stack
    res.sendStatus 500

# Connects to the database
mongoose.connect config.mongoConnectionString
connection = mongoose.connection

# Adds some event handlers for logging
connection.on 'open', log.debug.bind(log, 'Connection to MongoDB open')
connection.on 'close', log.debug.bind(log, 'Connection to MongoDB closed')
connection.on 'reconnected', log.debug.bind(log, 'Reconnected to MongoDB')
connection.on 'error', (e) -> log.error 'MongoDB connection error: ' + e.stack

# Starts the server once that the connection with MongoDB is opened
connection.once 'open', () ->
    if config.method == 'tcp'
        if not config.port
            throw new Error 'Please, provide the port setting.'
        if not config.bindIp
            throw new Error 'Please, provide the bindIp setting.'
        app.listen config.port, config.bindIp, () ->
            log.debug 'Listening on ' + config.bindIp + ':' + config.port
    else if config.method == 'unix'
        if not config.bindSocket
            throw new Error 'Please, provide the bindSocket setting.'
        if not config.socketPermissions
            throw new Error 'Please, provide the socketPermissions setting.'
        fs.stat config.bindSocket, (err) ->
            fs.unlinkSync config.bindSocket if not err
            app.listen config.bindSocket, () ->
                fs.chmodSync config.bindSocket, config.socketPermissions
                log.debug 'Listening on socket ' + config.bindSocket
    else
        throw new Error 'Invalid configuration value for method setting: ' + config.method
