import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:mlco/services/permissionService.dart';

Future<void> downloadreport(
    BuildContext context, List<int> fileBytes, filename) async {
  try {
    await requestStoragePermission();

    // Get the Downloads directory
    final Directory downloadsDir = Directory('/storage/emulated/0/Download');
    if (!downloadsDir.existsSync()) {
      throw Exception('Unable to access Downloads directory');
    }

    // Generate timestamp
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    final timestamp = formatter.format(now);

    // Define the file path with timestamp and create the file
    final String downloadPath =
        path.join(downloadsDir.path, '$filename$timestamp.xlsx');
    final File file = File(downloadPath);

    // Write PDF bytes to file
    // Write bytes to the file
    await file.writeAsBytes(fileBytes);
    print('File saved to: $downloadPath');

    // Show a local notification that the download is complete
    //await showDownloadNotification(downloadPath);

    // Show the download completion message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File downloaded successfully: $downloadPath'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // Open the file when the action button is pressed
            OpenFile.open(downloadPath);
          },
        ),
      ),
    );
  } catch (e) {
    print('Error downloading PDF: $e');
  }
}

// // Function to show a custom notification after download is complete
// Future<void> showDownloadNotification(String filePath) async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   final InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'download_channel',
//     'Download Notifications',
//     channelDescription: 'Notification for download tasks',
//     importance: Importance.high,
//     priority: Priority.high,
//     ticker: 'ticker',
//   );

//   final NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);

//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     'Download Complete',
//     'File downloaded: $filePath',
//     platformChannelSpecifics,
//     payload: filePath, // Pass the file path in case you want to use it later
//   );
// }

Future<void> onSelectNotification(String? payload) async {
  if (payload != null) {
    // Open the file using the `open_file` package
    OpenFile.open(payload);
  }
}
