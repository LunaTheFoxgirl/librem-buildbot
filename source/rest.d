module rest;
import irest;
import vibe.web.rest;

private static RestInterfaceClient!JenkinsRestBuildList build_list;
private static RestInterfaceClient!JenkinsRestJobDescription job_desc;

public JenkinsRestBuildList.Root GetBuildList(string root) {
	return build_list.getRoot(root);
}

public JenkinsRestJobDescription.Root GetJobDescription(string root, int id) {
	return job_desc.getRoot(root, id);
}

shared static this() {
	build_list = new RestInterfaceClient!JenkinsRestBuildList("https://arm01.puri.sm/");
	job_desc = new RestInterfaceClient!JenkinsRestJobDescription("https://arm01.puri.sm/");
}
