class DmgDetailModel {
  String dmgDetailId;
  String dmgDetailName;
  String dmgCateId;
  
  DmgDetailModel(this.dmgDetailId, this.dmgDetailName, this.dmgCateId);

  DmgDetailModel.fromJson(Map<String, dynamic> json) {

  }

  DmgDetailModel.fromJlist(String did, List<dynamic> json) {
    dmgDetailId = did;
    dmgDetailName = json[0];
    dmgCateId = json[1].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dmg_detail_id'] = this.dmgDetailId;
    data['dmg_detail_name'] = this.dmgDetailName;
    data['dmg_cate_id'] = this.dmgCateId;
    return data;
  }
}
