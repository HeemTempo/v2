import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';



  Future<void> showAccessDeniedDialog(BuildContext context,
      {String featureName = "this feature"}) async {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Access Denied',
      text: 'No access. You need to log in to use $featureName.',
      confirmBtnText: 'Login',
      showConfirmBtn: true,
      showCancelBtn: true,
      cancelBtnText: 'Cancel',
      confirmBtnColor: Theme
          .of(context)
          .primaryColor,
      onConfirmBtnTap: () {
        Navigator.of(context).pushNamed('/login');
      },
      onCancelBtnTap: () {
        Navigator.of(context).pop();
      },
      barrierDismissible: false,
    );
  }
