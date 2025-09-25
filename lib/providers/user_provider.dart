import 'package:flutter/material.dart';

import '../model/user_model.dart';


class UserProvider with ChangeNotifier {
  User _user = User.anonymous();

  User get user => _user;

  void setUser(User user) {
    _user = user;
    print('UserProvider: User set to ${user.username} (Anonymous: ${user.isAnonymous})');
    notifyListeners();
  }

  void logout() {
    _user = User.anonymous();
    print('UserProvider: Logged out, set to anonymous user');
    notifyListeners();
  }
}