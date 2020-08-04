import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// desc：显示对话框
/// barrierDismissible 点击对话框外取消
/// showBarrierColor是否显示对话框之外的灰色背景
Future<T> showLinkDialog<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
  showBarrierColor = true,
  WidgetBuilder builder,
}) {
  assert(builder != null);
  assert(debugCheckHasMaterialLocalizations(context));

  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return pageChild;
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: showBarrierColor ? Colors.black54 : null,
    transitionDuration: const Duration(milliseconds: 500),
    transitionBuilder: _buildMaterialDialogTransitions,
  );
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return ScaleTransition(
      scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
      child: child);
}

typedef OnDialogDismiss = void Function();

abstract class DialogInterface {
  bool showing = false;
  BuildContext currentContext;
  OnDialogDismiss onDialogDismiss;

  void setOnDialogDismissListener(OnDialogDismiss onDialogDismiss) {
    this.onDialogDismiss = onDialogDismiss;
  }

  Future<T> show<T>(BuildContext context);

  void cancel() {
    if (showing) {
      if (onDialogDismiss != null) {
        onDialogDismiss();
      }
      Navigator.pop(currentContext, false);
    }
  }
}
