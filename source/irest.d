module irest;
import vibe.web.rest;

public interface JenkinsRestBuildList {
	struct Root {
		Build[] Builds;
	}
	struct Build {
		int number;
		string url;
	}
	struct LastBuild {
		int number;
		string url;
	}

	@path(":root/api/json?pretty=true")
	Root getRoot(string _root);
}

public enum JobResult : string {
	Failure = "FAILURE",
	Success = "SUCCESS"
}

public interface JenkinsRestJobDescription {
	struct Root {
		Artifact[] artifacts;
		bool building;
		string description;
		string displayName;
		ulong duration;
		ulong estimatedDuration;
		string fullDisplayName;
		string id;
		bool keepLog;
		int number;
		int queueId;
		JobResult result;
		ulong timestamp;
		string url;
		Curlpit[] curlpits;
	}

	struct Curlpit {
		string absoluteUri;
		string fullName;
	}

	struct Artifact {
		string displayPath;
		string fileName;
		string relativePath;
	}

	@path(":root/:id/api/json?pretty=true")
	Root getRoot(string _root, int _id);
}
