express = require 'express'
app = express()
bodyParser = require 'body-parser'
yaml = require 'js-yaml'

# Common middlewares
app.use bodyParser.json()

# The one and only HTTP entry point
app.post '/', (req, res) ->
    console.log('POST:');
    console.log(require('util').inspect(req.body, {colors:true}));
    res.end();

app.listen(8002);
