# librem-buildbot
A small matrix client bot that posts whenever a new build of PureOS (arm) is built.

# Setup/Building
To build librem-buildbot, you will need libssl/openssl 1.1, aswell libcrypto. 

To build the project, run `dub build` in the root folder of the project, a file should be output that can be run; to run the bot.

Once built, you will need to create the configuration file, [example](https://github.com/Member1221/librem-buildbot/blob/master/example-config.json). Which you will need to put in `/var/librem-buildbot/config.json`.

Once that's done you should be able to run the bot.

# What does it do?
The bot queries the Purism Jenkins server every 5 minutes, to check if a new qemu build of PureOS has been built. 

The build will then be posted to whatever channels you have specified in the configuration file, including a download link to the ouput artifact.
