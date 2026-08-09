import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

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
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppConstants.darkText : AppConstants.navy;
    final secondary =
        isDark ? AppConstants.darkTextSecondary : AppConstants.muted;
    final border = isDark ? AppConstants.darkBorder : AppConstants.border;
    final surface = isDark ? AppConstants.darkCard : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: AppConstants.navy.withValues(alpha: isDark ? 0.14 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppConstants.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.attachmentsTitle,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      localizations.attachmentsHint,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: pickImages,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor:
                        isDark
                            ? AppConstants.primaryGreen.withValues(alpha: 0.2)
                            : AppConstants.primaryGreenSoft,
                    foregroundColor:
                        isDark
                            ? AppConstants.accentMint
                            : AppConstants.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.image_outlined, size: 19),
                  label: Text(
                    localizations.addPhotosButton,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickGeneralFiles,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: foreground,
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.attach_file_rounded, size: 19),
                  label: Text(
                    localizations.addDocumentsButton,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (selectedFileNames.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppConstants.darkCardAlt
                        : AppConstants.pageBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, color: secondary, size: 19),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      localizations.noAttachments,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(selectedFileNames.length, (index) {
                final fileName = selectedFileNames[index];
                return InputChip(
                  avatar: Icon(
                    _getFileIcon(fileName),
                    color: AppConstants.primaryGreen,
                    size: 18,
                  ),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onDeleted:
                      removeFile == null ? null : () => removeFile!(index),
                  deleteIconColor: AppConstants.danger,
                  backgroundColor:
                      isDark
                          ? AppConstants.darkCardAlt
                          : AppConstants.pageBackground,
                  side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                  labelStyle: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return Icons.image_rounded;
    }
    if (extension == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc', 'docx'].contains(extension)) return Icons.description_rounded;
    if (['xls', 'xlsx'].contains(extension)) return Icons.table_chart_rounded;
    if (extension == 'txt') return Icons.article_outlined;
    return Icons.insert_drive_file_rounded;
  }
}
