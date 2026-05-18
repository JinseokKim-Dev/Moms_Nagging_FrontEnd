import 'package:flutter/material.dart';

import '../home_logic.dart';
import '../home_widgets.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({
    super.key,
    required this.prepTimeMinutes,
    required this.onLogout,
    required this.onComingSoon,
  });

  final int prepTimeMinutes;
  final VoidCallback onLogout;
  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    return GradientPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: '설정',
              subtitle: '앱 사용 방식과 로그인 상태를 이 화면에서 관리할 수 있어요.',
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFEA580C),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mom Nagging 사용자',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '현재 준비 시간은 ${HomeFormatters.formatPrepTime(prepTimeMinutes)}으로 저장되어 있어요.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsItemCard(
              title: '준비 시간 설정',
              subtitle: '아침 루틴에 맞춰 기상 시간을 다시 계산할 수 있어요.',
              icon: Icons.tune_rounded,
              color: const Color(0xFF0F766E),
              onTap: () => onComingSoon('준비 시간 설정'),
            ),
            const SizedBox(height: 12),
            SettingsItemCard(
              title: '알림 및 진동',
              subtitle: '소리, 진동, 방해금지 예외 같은 옵션을 연결할 수 있어요.',
              icon: Icons.notifications_active_outlined,
              color: const Color(0xFF2563EB),
              onTap: () => onComingSoon('알림 및 진동'),
            ),
            const SizedBox(height: 12),
            SettingsItemCard(
              title: '음성/캐릭터 설정',
              subtitle: '앱의 말투나 캐릭터 반응을 나중에 이곳에서 바꿀 수 있어요.',
              icon: Icons.record_voice_over_rounded,
              color: const Color(0xFF9333EA),
              onTap: () => onComingSoon('음성/캐릭터 설정'),
            ),
            const SizedBox(height: 12),
            SettingsItemCard(
              title: '계정 및 보안',
              subtitle: '로그인 유지 상태와 세션 관련 기능을 확장하기 좋은 영역이에요.',
              icon: Icons.shield_outlined,
              color: const Color(0xFFEA580C),
              onTap: () => onComingSoon('계정 및 보안'),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '세션 관리',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '현재는 토큰을 저장해서 로그인 상태를 유지하고 있어요. 필요하면 여기서 로그아웃할 수 있게 해두었어요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C2D12),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB91C1C),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        '로그아웃',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
