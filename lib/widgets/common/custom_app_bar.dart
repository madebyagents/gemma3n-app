import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onMorePressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onMorePressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
      ),
      leading: onMenuPressed != null
          ? IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppColors.darkGray,
              ),
              onPressed: onMenuPressed,
            )
          : null,
      actions: actions ??
          [
            if (onMorePressed != null)
              IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.darkGray,
                ),
                onPressed: onMorePressed,
              ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 