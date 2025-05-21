import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ColorPickerItem extends StatelessWidget {
  final String colorName;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const ColorPickerItem({
    super.key,
    required this.colorName,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (colorName.toLowerCase()) {
      case 'tomato':
        color = AppColors.primaryRed;
        break;
      case 'blue':
        color = AppColors.primaryBlue;
        break;
      case 'green':
        color = AppColors.primaryGreen;
        break;
      case 'purple':
        color = AppColors.primaryPurple;
        break;
      default:
        color = AppColors.primaryRed;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}