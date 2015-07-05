fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'
_ = require 'lodash'

# Defaults
defaults =
    method: 'tcp'
    port: 8000
    bindIp: '0.0.0.0'
    socketPermissions: 0o666

    logPath: '/var/log/ClockworkBot.log'
    mongoConnectionString: "mongodb://localhost/ClockworkBot"

# Loads the configuration file
module.exports = _.defaults yaml.safeLoad(fs.readFileSync path.join __dirname, '..', 'config.yml'), defaults
