module bot;
import matrix.api;
import std.json;
import core.thread;
import rest;
import irest;

alias JobDescrRoot = JenkinsRestJobDescription.Root;

public class MatrixBOT {
	public MatrixAPI API;
	public string Host;
	public string User;
	public string BotToken;

	public int BuildID = 0;
	public string TargetRoomID;
	public int UpdateRate = 100;

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
		foreach (roomId; API.getRooms) {
			this.API.roomListener(new RoomListener(roomId, &onRoom));
		}
	}

	private int updateCounter = 0;
	public void Update() {
		this.API.poll();
		// Sleep for 100 milliseconds.
		Thread.sleep( dur!("msecs")( 100 ));
		updateCounter--;
		if (updateCounter < 0) {
			updateCounter = UpdateRate;
			JobDescrBox root = GetJenkinsInfo();
		}
	}

	public void onRoom(MatrixAPI api, string room, JSONValue context) {
		if (context["sender"].str != api.userId) {
			if (context["content"]["body"].str == "!buildinfo") {
				SendMessage(room, "*Wait a second, querying jenkins...*");
				JobDescrBox root = GetJenkinsInfo();
			}
		}
	}

	public void SendMessage(string id, string message) {
		this.API.sendHTML(id, message);
	}

	public JobDescrBox GetJenkinsInfo() {
		JenkinsRestBuildList.Root buildList = GetBuildList(config["api_root"].str);
		bool isQemuBuild = false;
		int iterator = 0;
		JobDescrRoot descr;
		while (!isQemuBuild) {
			descr = GetJobDescription(config["api_root"].str, buildList.Builds[iterator].number);
			if (descr.description == "qemu-x86_64.img.xz") {
				isQemuBuild = true;
			}
			iterator++;
			if (iterator >= buildList.Builds.length) return null;
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
