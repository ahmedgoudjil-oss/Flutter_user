import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/user.dart';
import 'package:untitled/services/shared_preferences_service.dart';

class UserProvider extends StateNotifier<User?> {
  //constructor initializing with default user object
  UserProvider()
    : super(
        User(
          id: "",
          fullName: "",
          email: "",
          state: "",
          city: "",
          locality: "",
          
          token: "",
          
        ),
      );
  //getter method to extract value from object
  User? get user => state;

  void setUser(String userJson) {
    state = User.fromJson(userJson);
    // Save user data to SharedPreferences
    SharedPreferencesService.saveUserData(userJson);
  }
// Method to clear user state
void signOut(){
  state = null;
  // Clear user data from SharedPreferences
  SharedPreferencesService.clearAuthData();
}
//Method to update user state
void recreateUserState({
  required String city,
  required String locality,
  required String state,
}){
  if(this.state != null) {
  this.state = User(
    id: this.state!.id,
    fullName: this.state!.fullName,
    email: this.state!.email,
    state: state,
    city: city,
    locality: locality,
    
    token: this.state!.token,
    
  );
  }

}

}
//هذا هو لي رايح نستعملوه في باقي التطبيق باش نقرأ وندير تحديث للمستخدم.
  final userProvider = StateNotifierProvider<UserProvider, User?>(
    (ref) => UserProvider(),
  );