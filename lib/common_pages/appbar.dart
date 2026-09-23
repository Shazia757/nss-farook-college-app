import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final height = 60.0;

    return PreferredSize(
      preferredSize: Size.fromHeight(height),

      child: AppBar(
        backgroundColor: cs.onPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset("assets/logos/logo.png", height: 50),
            ),
            SizedBox(width: 10),
            Text(
              'NSS Farook College',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outline.withOpacity(0.3)),
        ),
      ),
    );
  }
}
