class ActivityModel {
  String actId;
  int orderNo;
  String actName;
  String unit;
  
  ActivityModel(this.actId, this.orderNo, this.actName, this.unit);

  ActivityModel.fromJson(Map<String, dynamic> json) {

  }

  ActivityModel.fromJlist(String aid, List<dynamic> json) {
    actId = aid;
    actName = json[0];
    unit = json[1];
    orderNo = json[2];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['act_id'] = this.actId;
    data['order_no'] = this.orderNo;
    data['act_name'] = this.actName;
    data['unit'] = this.unit;
    return data;
  }
}
