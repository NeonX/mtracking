class ProjectModel {
  String prjId;
  String prjName;
  String prjCode;
  String jobType;
  String jobTypeId;
  String provId;
  String ampId;

  ProjectModel(this.prjId, this.prjName, this.prjCode,this.jobType, this.jobTypeId, this.provId, this.ampId);

  ProjectModel.fromJson(Map<String, dynamic> json) {

  }

  ProjectModel.fromJlist(String pid, List<dynamic> json) {
    prjId = pid;
    prjCode = json[0];
    prjName = json[1];
    jobType = json[2];
    jobTypeId = json[3];
    provId = json[4];
    ampId = json[5];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['prj_id'] = this.prjId;
    data['prj_name'] = this.prjName;
    data['prj_code'] = this.prjCode;
    data['job_type'] = this.jobType;
    data['job_type_id'] = this.jobTypeId;
    data['prov_id'] = this.provId;
    data['amp_id'] = this.ampId;
    return data;
  }
}
