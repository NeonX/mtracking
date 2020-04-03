class UserModel {

  // Field
  String id, name, user, password, avatar;


  // Method
  UserModel(this.id,this.name, this.user, this.password, this.avatar);

  UserModel.fromMap(Map<String, dynamic> map){
    id = map['id'];
    name = map['name'];
    user = map['user'];
    password = map['password'];
    avatar = map['avatar'];
  }


}