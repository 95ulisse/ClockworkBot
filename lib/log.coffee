winston = require 'winston'
config = require './config'

logger = new winston.Logger
    transports: [
        new winston.transports.Console(level: 'silly', colorize: true, prettyPrint: true),
        new winston.transports.File(filename: config.logPath, level: 'info', json: true,  handleExceptions: true)
    ]

module.exports = logger
