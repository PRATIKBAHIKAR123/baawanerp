import 'package:flutter/material.dart';
import 'package:mlco/services/permission_manager.dart';

class PermissionWrapper extends StatelessWidget {
  final String permissionId;
  final Widget child;
  final Widget? fallback;

  const PermissionWrapper({
    Key? key,
    required this.permissionId,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PermissionManager().isGranted(permissionId)) {
      return child;
    } else {
      return fallback ?? SizedBox.shrink();
    }
  }
}
