express = require 'express'
app = express()
bodyParser = require 'body-parser'
config = require './lib/config'
log = require './lib/log'

# Common middlewares
app.use bodyParser.json()

# Since Telegram might deliver out-of-order updates,
# we store all the non-sequential messages in memory
# to make sure that they are processed in the right order
updateQueue = do () ->
    lastId = -1
    queue = {}

    # Actual function used to process the updates
    processUpdate = (u) ->
        log.info "Processed ##{u.update_id}: #{u.message.text}"

    # Exports the function to push in the queue
    return (u) ->
        lastId = u.update_id - 1 if lastId == -1
        throw new Error('Duplicate update ID #' + u.update_id) if queue[u.update_id] or u.update_id <= lastId
        queue[u.update_id] = u
        log.debug 'Enqueued update #' + u.update_id

        u = queue[lastId + 1]
        while u
            processUpdate u
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

app.listen config.port, () ->
    log.debug 'Server listening on port ' + config.port
