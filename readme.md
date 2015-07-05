# Clockwork SMS Telegram bot

This is a simple Telegram bot that allows sending SMS through the [Clockwork SMS](http://www.clockworksms.com/) service.

For more information, look at the post on the [Telegram blog](https://telegram.org/blog/bot-revolution) and the [docs](https://core.telegram.org/bots/api).

**Note**: While the bot itself is free, the Clockwork SMS service is not. For more information, look at their [pricing](http://www.clockworksms.com/pricing/) page.

## Getting started

First of all, [install MongoDB](http://docs.mongodb.org/manual/installation/) and [NodeJS](https://nodejs.org/);

Then, clone the repository in a directory of your choice and initialize ClockworkBot:

```shell
git clone https://github.com/95ulisse/ClockworkBot.git
cd ClockworkBot
npm init
```

And finally, start the bot:

```shell
node .
```

Now, you should inform Telegram that there's a new bot ready out there!

```shell
curl -X GET https://api.telegram.org/bot<token>/setWebhook\?url\=<urlToReachTheBotServer>
```

## Configuration options

The config file is `config.yml`. These are the possible configuration options:

* `method`: _{unix|tcp}_ Indicates if a unix or tcp socket should be used.
* `bindIp`: IP address to bind to when `method` is _tcp_.
* `port`: Port to bind to when `method` is _tcp_.
* `bindSocket`: Path of the unix socket when `method` is _unix_.
* `socketPermissions`: Permissions of the unix socket when `method` is _unix_.
* `logPath`: Path to the log file
* `mongoConnectionString`: MongoDB connection string in the format `mongodb://<server>/<database>`. For more information look at the [MongoDB docs](http://docs.mongodb.org/manual/reference/connection-string/).
* `botKey`: API token provided by Telegram's BotFather.


## Commands

This is a list of all the commands that the bot accepts:

* `/setapikey <apiKey>`: Sets the Clockwork API Key to use to send messages. Pass `null` to delete the key.
* `/setdefaultfrom <number>`: Sets a default sender number to use when not specified in the `/sms` command. Pass `null` to delete the default sender.
* `/sms [from <senderNumber> to] <destNumber> <message>`: Sends an SMS to _<destNumber>_. Specifying a sender number is optional, and if not provided will be used the default one (see `/setdefaultfrom`).
* `/credit`: Check the how much credit is left on your Clockwork account
* `/help`: Shows the help text.

## License

This software is licensed under the MIT license.
