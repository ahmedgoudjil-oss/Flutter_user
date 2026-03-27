import 'dart:convert';
class User {
  final String id ;
  final String fullName ;
  final String email ;
  final String state ;
  final String city  ;
  final String locality ;
  final String password ;
  final String token;
  User({required this.id, required this.fullName, required this.email, required this.state, required this.city, required this.locality, required this.password,required this.token});

 
  //serialization: convert user object to a Map
  //why: converting to a map is an intermediate step that makes it easier to serialize
  //the object to formates like json for storage or transmission

  //هذه الدالة تحوّل الكائن User إلى Map.//

  //لماذا؟ لأنه من السهل بعد ذلك تحويل Map إلى JSON أو تخزينه في قاعدة بيانات.
Map<String,dynamic> toMap() {
  return <String,dynamic> {
    "id":id,
    "fullName":fullName,
    "email":email,
    "state":state,
    "city":city,
    "locality":locality,
    "password":password,
     "token":token,
  };
}

//serialization: convert map to a json string
 // تحويل الكائن إلى JSON string باستخدام json.encode.
 // تعتمد على toMap() أولًا ثم تحوّله إلى سلسلة نصية بصيغة JSON.

  String toJson()=> json.encode(toMap());
  // the json.encode() function converts the Map returned by toMap() into a JSON string.
 // deserialization: convert a Map to a User object
  factory User.fromMap(Map<String,dynamic>map){
  return User(
      id: map['_id'] as String? ??"",
      fullName : map['fullName'] as String? ??"",
      email: map['email'] as String? ??"",
      state: map['state'] as String? ??"",
      city: map['city'] as String? ??"",

      locality: map['locality'] as String? ??"",
      password: map['password'] as String? ??"",
      token: map['token'] as String? ??"",
  );

}

//هو دالة factory constructor إضافية تُستخدم لتحويل نص JSON مباشرة إلى كائن من نوع User.
factory User.fromJson(String source)=> User.fromMap(jsonDecode(source)as Map<String,dynamic>);


}