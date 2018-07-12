import bot;
import std.file;
import std.stdio;
import std.json;

void main(string[] args) {
	string location = "/var/librem-buildbot/config.json";
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
