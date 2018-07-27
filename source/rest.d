module rest;
import irest;
import vibe.web.rest;
import vibe.core.path;
import std.stdio;
import std.string;

private static RestInterfaceClient!JenkinsRestBuildList build_list;
private static RestInterfaceClient!JenkinsRestJobDescription job_desc;
private static string res_root;

public JenkinsRestBuildList.Root GetBuildList() {
	writeln("API::JenkinsRestBuildList ", res_root, "/api/json");
	return build_list.getRoot();
}

public JenkinsRestJobDescription.Root GetJobDescription(int id) {
	writeln("API::JenkinsRestJobDescription ", res_root, id, "/api/json");
	return job_desc.getRoot(id);
}

public static void Purge() {
	destroy(build_list);
	destroy(job_desc);
}

public static void Init(string root) {
	string path = "https://arm01.puri.sm/"~(root.replace(" ", "%20"));
	res_root = path;
	try {
		build_list = new RestInterfaceClient!JenkinsRestBuildList(res_root);
		job_desc = new RestInterfaceClient!JenkinsRestJobDescription(res_root);
	} catch (PathValidationException ex) {
		writeln(ex.message, res_root);
	}
}
