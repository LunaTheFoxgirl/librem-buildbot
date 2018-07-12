module irest;
import vibe.web.rest;

public interface JenkinsRestBuildList {
	struct Root {
		Build[] builds;
	}
	struct Build {
		int number;
		string url;
	}
	struct LastBuild {
		int number;
		string url;
	}

	@path("/api/json")
	Root getRoot();
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
		Culprit[] culprits;
	}

	struct Culprit {
		string absoluteUrl;
		string fullName;
	}

	struct Artifact {
		string displayPath;
		string fileName;
		string relativePath;
	}

	@path("/:id/api/json")
	Root getRoot(int _id);
}
