import 'package:flutter/material.dart';
import '../sections/dialogs/create_section_session_dialog.dart';

class AddChapterDialog extends StatelessWidget {
  const AddChapterDialog({super.key});

  static Future<void> show(BuildContext context) {
    return CreateSectionSessionDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return const CreateSectionSessionDialog();
  }
}
