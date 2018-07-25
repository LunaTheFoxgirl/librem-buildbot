import bot;
import std.file;
import std.stdio;
import std.json;
import vibe.core.log;

// Uncomment the line below to enable extensive debug logging.
//version = VERBOSE;

void main(string[] argsx) {
	string location = "/var/librem-buildbot/config.json";
	string[] args = argsx[1..$];

	version(VERBOSE) {
		setLogLevel(LogLevel.trace);
	}

	if (args.length > 0) {
		location = args[0];
	}

	try {
		string configstr = readText(location);

		JSONValue config = parseJSON(configstr);

		MatrixBOT bot = new MatrixBOT(config["host"].str, config["username"].str, config["password"].str, config);
		while(true) {
			bot.Update();
		}
	} catch(FileException) {
		writeln("Could not find file ", location, ", please create it.");
	}
}
