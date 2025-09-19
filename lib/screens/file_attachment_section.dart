// screens/file_attachment_section.dart
import 'package:flutter/material.dart';

class FileAttachmentSection extends StatelessWidget {
  final List<String> selectedFileNames;
  final Future<void> Function()? pickImages;
  final Future<void> Function()? pickGeneralFiles;
  final void Function(int)? removeFile;

  const FileAttachmentSection({
    super.key,
    required this.selectedFileNames,
    this.pickImages,
    this.pickGeneralFiles,
    this.removeFile,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if buttons are enabled to style them accordingly
    final bool canPickImages = pickImages != null;
    final bool canPickGeneralFiles = pickGeneralFiles != null;
    final Color enabledButtonColor = Theme.of(context).colorScheme.primary; // Or your preferred color
    final Color disabledButtonColor = Colors.grey.shade400;

    return Card(
      elevation: 2, 
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Attach Files (Optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickImages,
                    icon: Icon(
                      Icons.image_outlined,
                      color: canPickImages ? enabledButtonColor : disabledButtonColor,
                    ),
                    label: Text(
                      "Add Images",
                      style: TextStyle(
                        color: canPickImages ? enabledButtonColor : disabledButtonColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: canPickImages ? enabledButtonColor : disabledButtonColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Spacing between buttons
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickGeneralFiles,
                    icon: Icon(
                      Icons.attach_file,
                      color: canPickGeneralFiles ? enabledButtonColor : disabledButtonColor,
                    ),
                    label: Text(
                      "Other Files",
                      style: TextStyle(
                        color: canPickGeneralFiles ? enabledButtonColor : disabledButtonColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: canPickGeneralFiles ? enabledButtonColor : disabledButtonColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedFileNames.isEmpty)
              Center( // Centering the "No Files Chosen" text
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "No Files Chosen",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFileNames.length,
                  itemBuilder: (context, index) {
                    final fileName = selectedFileNames[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        avatar: Icon(
                          _getFileIcon(fileName),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          fileName.length > 20 ? '${fileName.substring(0, 17)}...' : fileName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        deleteIcon: Icon(Icons.close, size: 18, color: Colors.red.shade400),
                        onDeleted: removeFile != null ? () => removeFile!(index) : null,
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // More rounded chips
                            side: BorderSide(color: Colors.grey.shade300)
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return Icons.image;
    } else if (['pdf'].contains(extension)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(extension)) {
      return Icons.description;
    } else if (['xls', 'xlsx'].contains(extension)) {
      return Icons.table_chart;
    } else if (['txt'].contains(extension)) {
      return Icons.article_outlined;
    }
    return Icons.insert_drive_file; // Default
  }
}