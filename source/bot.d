module bot;
import matrix.api;
import std.json;
import std.string;
import std.array;
import core.thread;
import std.stdio;
import rest;
import irest;
import std.algorithm;
import format;

alias JobDescrRoot = JenkinsRestJobDescription.Root;

public class MatrixBOT {
	public MatrixAPI API;
	public string Host;
	public string User;
	public string BotToken;

	public int BuildID = 0;
	private int oBuildId = 0;
	private bool isBuilding = false;
	public string[] Rooms;
	public string[] Administrators;
	private int minUpdateRate = 300;
	private int maxUpdateRate = 600;

	JSONValue config;


	this(string host, string user, string password, JSONValue extraConfig) {
		// Create new API.
		this.API = new MatrixAPI();

		// Fill API data.
		this.API.url = host;
		this.API.userId = user;
		this.API.password = password;
		this.API.token = "";

		// Login
		this.API.login();

		// Set newly generated token.
		this.BotToken = this.API.token;

		this.config = extraConfig;

		string[] rooms = API.getRooms;
		foreach(JSONValue room; extraConfig["rooms"].array()) {
			Rooms ~= room.str;
			if (!rooms.canFind(room.str)) {
				JoinRoom(room.str);
			}
		}

		foreach(JSONValue admin; extraConfig["admins"].array()) {
			Administrators ~= admin.str;
		}

		Init(extraConfig["api_root"].str);

		// Update, in case new rooms were joined.
		rooms = API.getRooms;
		foreach (roomId; rooms) {
			this.API.roomListener(new RoomListener(roomId, &onRoom));
		}
	}

	private int updateCounter = 0;
	public void Update() {
		this.API.poll();
		// Sleep for 100 milliseconds.
		Thread.sleep( dur!("msecs")( 1000 ));
		updateCounter--;
		if (updateCounter < 0) {
			JobDescrBox root = GetJenkinsInfo();
			foreach(room; API.getRooms) {
				if (root is null) {
					SendMessage(room, "**ERROR** Could not find any builds <i>at all</i>, is the server down?");
					return;
				}
				SendMessage(room, root.root);
			}
			if (!isBuilding) BuildID = oBuildId;

			updateCounter = minUpdateRate;
			if (isBuilding) updateCounter = maxUpdateRate;
		}
	}

	public void JoinRoom(string roomid) {
		if (API.getRooms.canFind(roomid)) return;
		this.API.joinRoom(roomid);
		SendMessage(roomid, "librem-buildbot has joined!");
	}

	public void onRoom(MatrixAPI api, string room, JSONValue context) {
		if (context["sender"].str != api.userId) {
			if ("body" in context["content"]) {
				string[] command = context["content"]["body"].str.split(' ');
				if (command[0] == "!join") {
					if (command.length != 2) {
						SendMessage(room, "**Invalid command usage!** `!join (room id)` is the right syntax c:");
						return;
					}
					if (GetAdmin(context["sender"].str)) {
						string roomid = command[1];
						SendMessage(room, "*Joining now...*");
						JoinRoom(roomid);
					} else {
						SendMessage(room, "**You do not have permission to invite this bot in to a room.**");
						return;
					}
				}

				if (command[0] == "!buildinfo") {
					SendMessage(room, "<i>Wait a second, querying jenkins...</i>");
					JobDescrBox root = GetJenkinsInfo();
					if (root is null) {
						SendMessage(room, "**ERROR** Could not find any builds *at all*, is the server down?");
						return;
					}
					SendMessage(room, root.root, false);
				}
			}
		}
	}

	public bool GetAdmin(string senderid) {
		return Administrators.canFind(senderid);
	}

	private string getCulpritsString(JenkinsRestJobDescription.Culprit[] culprits) {
		string output = "<Server Trigger>";
		if (culprits.length > 0) {
			output = culprits[0].fullName~" ";
			foreach (i; 1 .. culprits.length) {
				if (i == culprits.length-1) output ~= culprits[i].fullName;
				else if (i == culprits.length-2) output ~= culprits[i].fullName~" and ";
				else output ~= culprits[i].fullName~", ";
			}
		}
		return output;
	}

	public void SendMessage(string roomid, JobDescrRoot root, bool avoid_resend = true) {
		if (avoid_resend && root.number == BuildID) return;
		if (root.building) isBuilding = true;
		string culprits = getCulpritsString(root.culprits);
		if (!isBuilding || !root.building) {
			string artifact = Format("<0><1><2>/artifact/<3>", "https://arm01.puri.sm/", config["api_root"].str, root.number, root.artifacts[0].fileName).replace(" ", "%20");
			SendMessage(roomid, Format("<b><0>'s queued QEMU build has completed!</b>\nBuild ID: <1>\nResult: <2>\nDownload Here: <3>", culprits, root.number, root.result, artifact));
			isBuilding = false;
			return;
		}
		if (root.building) {
			SendMessage(roomid, Format("<b><0>'s queued QEMU build is currently building!...</b>\nBuild ID: <1>", culprits, root.number));
			return;
		}
	}

	public void SendMessage(string roomid, string message) {
		this.API.sendHTML(roomid, message);
	}

	public JobDescrBox GetJenkinsInfo() {
		JenkinsRestBuildList.Root buildList = GetBuildList();
		bool isQemuBuild = false;
		int iterator = 0;
		JobDescrRoot descr;
		while (!isQemuBuild) {
			try {
				descr = GetJobDescription(buildList.builds[iterator].number);
			} catch (Throwable) {
				iterator++;
				Thread.sleep( dur!("msecs")( 500 ));
				continue;
			}
			writeln(descr.description);
			if (descr.description == "qemu-x86_64 image") {
				isQemuBuild = true;
				oBuildId = buildList.builds[iterator].number;
			}
			iterator++;
			if (iterator >= buildList.builds.length) return null;
			Thread.sleep( dur!("msecs")( 500 ));
		}
		return new JobDescrBox(descr);
	}

}

class JobDescrBox {
	this(JobDescrRoot root) {
		this.root = root;
	}

	JobDescrRoot root;
}

public static MatrixBOT Bot;
