import 'package:flutter/material.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _BottomBarItem(label: '홈', icon: Icons.home_rounded),
      _BottomBarItem(label: '알람', icon: Icons.alarm_rounded),
      _BottomBarItem(label: '설정', icon: Icons.settings_rounded),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.08),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFEDD5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF9A3412)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomBarItem {
  const _BottomBarItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
