// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:html' as html;

// class PwaInstallButton extends StatefulWidget {
//   const PwaInstallButton({Key? key}) : super(key: key);

//   @override
//   State<PwaInstallButton> createState() => _PwaInstallButtonState();
// }

// class _PwaInstallButtonState extends State<PwaInstallButton> {
//   bool installAvailable = false;

//   @override
//   void initState() {
//     super.initState();

//     if (kIsWeb) {
//       html.window.addEventListener('pwaInstallAvailable', (_) {
//         if (!mounted) return;
//         setState(() {
//           installAvailable = true;
//         });
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!installAvailable) return const SizedBox();

//     return ElevatedButton.icon(
//       icon: const Icon(Icons.download),
//       label: const Text("Install App"),
//       onPressed: () {},
//     );
//   }
// }
