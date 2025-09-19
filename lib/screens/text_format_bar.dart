import 'package:flutter/material.dart';

class TextFormatBar extends StatelessWidget {
  const TextFormatBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFormatButton(Icons.format_bold),
            _buildFormatButton(Icons.format_italic),
            _buildFormatButton(Icons.format_underline),
            const VerticalDivider(thickness: 1),
            _buildFormatButton(Icons.format_list_bulleted),
            _buildFormatButton(Icons.format_list_numbered),
            const VerticalDivider(thickness: 1),
            _buildFormatButton(Icons.link),
            _buildFormatButton(Icons.insert_photo),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: () {},
      color: Colors.grey.shade700,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
