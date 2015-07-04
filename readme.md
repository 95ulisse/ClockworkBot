# Commands

This is a list of all the commands that the bot accepts:

* `/setapikey <apiKey>`: Sets the Clockwork API Key to use to send messages. Pass `null` to delete the key.
* `/setdefaultfrom <number>`: Sets a default sender number to use when not specified in the `/sms` command. Pass `null` to delete the default sender.
* `/sms [from <senderNumber> to] <destNumber> <message>`: Sends an SMS to _<destNumber>_. Specifying a sender number is optional, and if not provided will be used the default one (see `/setdefaultfrom`).
* `/credit`: Check the how much credit is left on your Clockwork account
* `/help`: Shows the help text.
