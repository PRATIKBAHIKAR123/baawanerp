import 'package:flutter/material.dart';
import 'package:mlco/common-widgets/emailshare-dialog.dart';
import 'package:mlco/common-widgets/invoice-dialog.dart';
import 'package:mlco/common-widgets/invoiceview.dart';
import 'package:mlco/common-widgets/whatsappshare-dialog.dart';
import 'package:mlco/global/invoiceTypes.dart';
import 'package:mlco/services/permission_manager.dart';
import 'package:mlco/config/app_permissions.dart';

Future<void> showCustomPopupMenu({
  required BuildContext context,
  required Offset position,
  required String id,
  int? invType,
  Map<String, dynamic>? invoice,
  InvoiceType? invoiceType,
  int? permissionId,
  int? utilityPermissionId,
  //required Function(String) onSelected,
}) async {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  await showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(
        position.dx,
        position.dy,
        0,
        0,
      ),
      Offset.zero & overlay.size,
    ),
    items: [
      if (permissionId == null ||
          PermissionManager().isGranted(permissionId)) ...[
        PopupMenuItem<String>(
          value: 'View',
          child: Text('View'),
        ),
      ],
      if (utilityPermissionId == null ||
          PermissionManager().isGranted(utilityPermissionId)) ...[
        PopupMenuItem<String>(
          value: 'Print',
          child: Text('Print'),
        ),
        PopupMenuItem<String>(
          value: 'WhatsApp',
          child: Text('WhatsApp'),
        ),
        PopupMenuItem<String>(
          value: 'E-Mail',
          child: Text('E-Mail'),
        ),
      ],
    ],
    elevation: 8.0,
  ).then((value) {
    if (value != null) {
      switch (value) {
        case 'View':
          // Handle edit action
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InvoiceViewScreen(
                      id: id,
                      invTypeID: invType,
                    )),
          );
          break;
        case 'Print':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return InvoiceDialog(
                invoice: invoice,
                id: id,
                invType: invType,
              );
            },
          );
          break;
        case 'WhatsApp':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WhatsAppPopup(
                invoice: invoice,
                id: id,
                invoiceType: invoiceType,
                invType: invType,
              );
            },
          );
          break;
        case 'E-Mail':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return EMailPopup(
                invoice: invoice,
                id: id,
                invoiceType: invoiceType,
                invType: invType,
              );
            },
          );
          break;
        default:
          break;
      }
    }
  });
}
