fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'

# Just load the configuration file
module.exports = yaml.safeLoad fs.readFileSync path.join __dirname, '..', 'config.yml'
