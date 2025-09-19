import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';



Future<void> showAccessDeniedDialog(BuildContext context,
    {String featureName = "this feature"}) async {
  return QuickAlert.show(
    context: context,
    type: QuickAlertType.loading,
    title: '',
    text: '',
    showCancelBtn: true,
    cancelBtnText: 'Cancel',
    onCancelBtnTap: () {
      Navigator.of(context).pop();
    },
    barrierDismissible: true,
  );
}
