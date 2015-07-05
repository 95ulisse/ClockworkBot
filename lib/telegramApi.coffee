request = require 'request'
config = require './config'

if not config.botKey
    throw new Error 'Please, provide the bot key.'

# Base URL for API calls
baseUrl = "https://api.telegram.org/bot#{config.botKey}/"

module.exports = (methodName, params) ->
    return new Promise (resolve, reject) ->
        request baseUrl + methodName, { form: params }, (err, httpResponse, body) ->

            return reject err if err

            res = JSON.parse body
            if not res.ok
                reject res
            else
                resolve res.result
