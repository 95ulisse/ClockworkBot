clockwork = require 'clockwork'

# This is just a Promise-wrapper around the clockwork module
module.exports =

    getBalance: (apiKey) ->
        return new Promise (resolve, reject) ->
            clockwork(key : apiKey).getBalance (e, res) ->
                if e
                    reject e
                else
                    resolve res

    sendSms: (apiKey, from, to, contents) ->
        return new Promise (resolve, reject) ->
            clockwork(key : apiKey).sendSms From: from, To: to, Content: contents, (e, res) ->
                # Yep, the clockwork module is a bit inconsistent here
                if e and not e.ErrNo and not e.ErrDesc
                    reject e
                else if e and e.ErrNo and e.ErrDesc
                    resolve e
                else
                    resolve res
