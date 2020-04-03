class ImageModel {
  String imgUrl, desc, idate;


  static final columnUrl = 'img_url';
  static final columnDesc = 'img_desc';
  static final columnDate = 'img_date';

  ImageModel({this.imgUrl, this.desc, this.idate});

  ImageModel.fromJson(Map<String, dynamic> json) {
    imgUrl = json[columnUrl];
    desc = json[columnDesc];
    idate = json[columnDate];
  
  }
}