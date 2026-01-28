import 'package:flutter/material.dart';

import 'package:mlco/services/permission_manager.dart';

class PermissionAwareWidget extends StatelessWidget {
  final int? permissionId;
  final List<int>? anyOf;
  final Widget child;

  const PermissionAwareWidget({
    Key? key,
    this.permissionId,
    this.anyOf,
    required this.child,
  })  : assert(permissionId != null || anyOf != null,
            'Either permissionId or anyOf must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check permission
    bool granted = false;

    if (permissionId != null) {
      granted = PermissionManager().isGranted(permissionId!);
    } else if (anyOf != null) {
      granted = anyOf!.any((id) => PermissionManager().isGranted(id));
    }

    if (granted) {
      return child;
    }
    // Otherwise, show an empty container
    return SizedBox.shrink();
  }
}
