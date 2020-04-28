class DmgCategoryModel {
  String dmgCateId;
  String dmgCateName;
  int orderNo;
  
  DmgCategoryModel(this.dmgCateId, this.dmgCateName, this.orderNo);

  DmgCategoryModel.fromJson(Map<String, dynamic> json) {

  }

  DmgCategoryModel.fromJlist(String did, List<dynamic> json) {
    dmgCateId = did;
    dmgCateName = json[0];
    orderNo = json[1];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dmg_cate_id'] = this.dmgCateId;
    data['dmg_cate_name'] = this.dmgCateName;
    data['order_no'] = this.orderNo;
    return data;
  }
}
