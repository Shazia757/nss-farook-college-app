import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:nss_new/config/urls.dart';

typedef StringValueOf<T> = String Function(T item);

class CustomWidgets {
  Card textField({
    required TextEditingController controller,
    required String label,
    EdgeInsets margin = const EdgeInsets.symmetric(vertical: 5),
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10),
    TextInputType? keyboardType,
    bool isEnabled = true,
    bool readOnly = false,
    bool? hideText,
    TextStyle? labelStyle,
    void Function()? onTap,
    List<TextInputFormatter>? inputFormatters,
    double elevation = 2,
    String? errorText,
    Widget? suffix,
    Color? color,
    int maxlines = 1,
    String? hintText,
    Widget? prefix,
  }) {
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          enabled: isEnabled,
          onTap: onTap,
          obscureText: hideText ?? false,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          maxLines: maxlines,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            labelText: label,
            border: InputBorder.none,
            labelStyle: labelStyle,
            suffix: suffix,
            prefix: prefix,
          ),
        ),
      ),
    );
  }

  Widget buildActionButton({
    IconData? icon,
    required BuildContext context,
    required String text,
    Color? color,
    required VoidCallback onPressed,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    Color foregroundColor = Colors.white,
  }) {
    return Padding(
      padding: padding,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: color,
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget buildLabel(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 16.0),
      child: Text(
        text,
        style: tt.labelLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(
    BuildContext context,
    String hintText, {
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.3)),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cs.outline.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
    );
  }

  Widget buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget searchableDropDown<T>({
    required BuildContext context,
    required TextEditingController controller,
    required StringValueOf<T> stringValueOf,
    required void Function(T) onSelected,
    void Function(String)? onChanged,
    required List<T> selectionList,
    TextInputType? keyboardType,
    required String label,
    bool show = true,
  }) {
    return TypeAheadField<T>(
      controller: controller,
      hideKeyboardOnDrag: true,
      hideOnUnfocus: true,
      debounceDuration: const Duration(milliseconds: 300),

      // Suggestions box
      decorationBuilder: (context, child) {
        return Material(
          color: Colors.white, // White dropdown background
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: child,
        );
      },

      builder: (context, textController, focusNode) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: CustomWidgets()
              .buildInputDecoration(context, label)
              .copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
        );
      },

      suggestionsCallback: (search) {
        return selectionList.where((element) {
          return stringValueOf(
            element,
          ).toLowerCase().contains(search.trim().toLowerCase());
        }).toList();
      },

      itemBuilder: (context, item) {
        final isSelected = controller.text == stringValueOf(item);

        return Container(
          color: isSelected ? Colors.grey.shade200 : Colors.white,
          child: ListTile(title: Text(stringValueOf(item))),
        );
      },

      onSelected: (item) {
        controller.text = stringValueOf(item);
        onSelected(item);
      },
    );
  }

  void showConfirmationDialog({
    required String title,
    String? message,
    Widget? content,
    required VoidCallback onConfirm,
    required Widget data,
  }) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(title),
          content: (message != null) ? Text(message) : content,
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
            TextButton(onPressed: () => onConfirm(), child: data),
          ],
        );
      },
    );
  }

  static void showSnackBar(
    String title,
    String message, {
    Widget? icon = const Icon(Icons.info_outline, color: Colors.white),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
  }) {
    if (Get.context == null && Get.testMode) return;
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        messageText: Text(
          message,
          style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.9)),
        ),
        isDismissible: true,
        duration: const Duration(seconds: 3),
        icon: icon,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        snackStyle: SnackStyle.FLOATING,
        barBlur: 15,
        backgroundColor: backgroundColor,
        boxShadows: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget footer() {
    return Column(
      children: [
        Text(
          "Developed by Bvoc Software Development",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "version ${Details.appVersion}",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        ),
        SizedBox(height: 50),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withOpacity(.15),
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    color: textColor.withOpacity(.9),
                  ),
                ),
                const SizedBox(height: 2),

                Text(
                  value,
                  style: tt.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
