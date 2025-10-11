// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:openspace_mobile_app/providers/report_provider.dart';
// import 'package:openspace_mobile_app/model/Report.dart';
// import 'package:openspace_mobile_app/utils/constants.dart';

// class PendingReportsPage extends StatefulWidget {
//   const PendingReportsPage({super.key});

//   @override
//   State<PendingReportsPage> createState() => _PendingReportsPageState();
// }

// class _PendingReportsPageState extends State<PendingReportsPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       final reportProvider = context.read<ReportProvider>();
//       reportProvider.syncPendingReports();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pending Reports'),
//         centerTitle: true,
//         backgroundColor: AppConstants.primaryBlue,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: () {
//               context.read<ReportProvider>().syncPendingReports();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Syncing pending reports...')),
//               );
//             },
//             tooltip: 'Sync Now',
//           ),
//         ],
//       ),
//       body: Consumer<ReportProvider>(
//         builder: (context, provider, child) {
//           final pendingReports = provider.pendingReports;

//           if (provider.isSubmitting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (pendingReports.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.check_circle_outline,
//                       size: 80, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No Pending Reports',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'All reports have been synced',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () => provider.syncPendingReports(),
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: pendingReports.length,
//               itemBuilder: (context, index) {
//                 final report = pendingReports[index];
//                 return _PendingReportCard(report: report);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _PendingReportCard extends StatelessWidget {
//   final Report report;

//   const _PendingReportCard({required this.report});

//   @override
//   Widget build(BuildContext context) {
//     final hasAttachment =
//         report.filePath != null && File(report.filePath!).existsSync();

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // STATUS BADGE
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.orange[100],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.cloud_off,
//                           size: 16, color: Colors.orange[900]),
//                       const SizedBox(width: 6),
//                       Text(
//                         'PENDING SYNC',
//                         style: TextStyle(
//                           color: Colors.orange[900],
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   DateFormat('MMM dd, yyyy').format(report.createdAt),
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // REPORT DETAILS
//             _DetailRow(
//               icon: Icons.person,
//               label: 'Reporter',
//               value: report.username,
//             ),
//             const SizedBox(height: 8),
//             _DetailRow(
//               icon: Icons.phone,
//               label: 'Contact',
//               value: report.contact ?? 'N/A',
//             ),
//             const SizedBox(height: 8),
//             _DetailRow(
//               icon: Icons.location_on,
//               label: 'Location',
//               value: report.locationName ?? 'Unknown',
//             ),
//             const SizedBox(height: 8),
//             _DetailRow(
//               icon: Icons.report_problem,
//               label: 'Type',
//               value: report.reportType,
//             ),
//             const SizedBox(height: 8),
//             _DetailRow(
//               icon: Icons.description,
//               label: 'Description',
//               value: report.description ?? 'No description provided',
//             ),

//             const SizedBox(height: 12),

//             // FILE VIEWER SECTION
//             _FileViewer(hasAttachment: hasAttachment, filePath: report.filePath),

//             const SizedBox(height: 16),

//             // INFO BOX
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue[200]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'This report will be automatically submitted once your device reconnects to the internet.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue[900],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _FileViewer extends StatelessWidget {
//   final bool hasAttachment;
//   final String? filePath;

//   const _FileViewer({
//     required this.hasAttachment,
//     this.filePath,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return hasAttachment
//         ? GestureDetector(
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (_) => Dialog(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       File(filePath!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               height: 150,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 image: DecorationImage(
//                   image: FileImage(File(filePath!)),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(
//                 alignment: Alignment.bottomRight,
//                 padding: const EdgeInsets.all(6),
//                 child: const Icon(
//                   Icons.zoom_in,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//               ),
//             ),
//           )
//         : Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.attach_file, color: Colors.grey[700]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'No file attached',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _DetailRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 18, color: AppConstants.primaryBlue),
//         const SizedBox(width: 8),
//         SizedBox(
//           width: 80,
//           child: Text(
//             '$label:',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
