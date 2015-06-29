request = require 'request'
config = require './config'

# Base URL for API calls
baseUrl = "https://api.telegram.org/bot#{config.apiKey}/"

module.exports = (methodName, params) ->
    return new Promise (resolve, reject) ->
        request baseUrl + methodName, { form: params }, (err, httpResponse, body) ->

            return reject err if err

            res = JSON.parse body
            if not res.ok
                reject res
            else
                resolve res.result
