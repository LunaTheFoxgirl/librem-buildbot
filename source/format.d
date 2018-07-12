module format;
import std.conv;
import std.array;
import std.stdio;
import core.vararg;

public static string Format(T...)(string format, T args) {
	string result = format;
	static foreach(i; 0 .. args.length) {
		result = result.replace("<" ~ i.text ~ ">", args[i].text);
	}
	return result;
}
