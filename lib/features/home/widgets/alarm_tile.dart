import 'package:flutter/material.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    super.key,
    required this.accent,
    required this.title,
    required this.time,
    required this.schedule,
    required this.note,
    required this.enabled,
    this.onEnabledChanged,
    this.onEdit,
    this.onDelete,
  });

  final Color accent;
  final String title;
  final String time;
  final String schedule;
  final String note;
  final bool enabled;
  final ValueChanged<bool>? onEnabledChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final canToggle = onEnabledChanged != null;
    final canEdit = onEdit != null;
    final canDelete = onDelete != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    schedule,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (canToggle)
                Switch.adaptive(
                  value: enabled,
                  onChanged: onEnabledChanged,
                  activeThumbColor: accent,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    enabled ? '활성화' : '꺼짐',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              if (canEdit || canDelete) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    if (canEdit)
                      TextButton.icon(
                        onPressed: onEdit,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('수정'),
                      ),
                    if (canDelete)
                      TextButton.icon(
                        onPressed: onDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('삭제'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
