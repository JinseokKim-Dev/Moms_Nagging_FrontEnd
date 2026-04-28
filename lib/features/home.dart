import 'package:flutter/material.dart';

// HomePage는 내부 상태를 직접 바꾸지 않는 단순 결과 화면이라
// StatefulWidget이 아니라 StatelessWidget으로 만들었다.
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.prepTimeMinutes});

  // 사용자가 앞 화면에서 설정한 준비 시간(분 단위)
  // null이면 아직 준비 시간이 전달되지 않은 경우다.
  final int? prepTimeMinutes;

  // 화면에 보여줄 때는 "65분"보다 "1시간 5분"이 더 읽기 쉬우므로
  // 분 단위 값을 시간/분 형식 문자열로 변환해 주는 helper 메서드다.
  String _formatPrepTime(int minutes) {
    // ~/ 는 Dart의 정수 나눗셈이다.
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    // 1시간 5분 같은 형태
    if (hours > 0 && remainingMinutes > 0) {
      return '$hours시간 $remainingMinutes분';
    }

    // 2시간 같이 딱 떨어지는 형태
    if (hours > 0) {
      return '$hours시간';
    }

    // 60분 미만은 그대로 분만 보여준다.
    return '$minutes분';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold는 기본적인 화면 뼈대(appBar, body 등)를 제공한다.
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // Center는 자식 위젯을 화면 가운데에 배치한다.
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),

          // BoxDecoration으로 카드 같은 흰색 박스를 만든다.
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),

          // Column은 아이콘, 텍스트들을 세로로 쌓아 준다.
          child: Column(

            // 세로로 필요한 만큼만 차지해서 카드 높이가 과도하게 커지지 않게 한다.
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 72,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                '로그인되었습니다.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                // 삼항 연산자(condition ? a : b)로
                // 준비 시간이 있는 경우와 없는 경우 문구를 나눠서 보여준다.
                prepTimeMinutes == null
                    ? '이제 홈 화면을 연결하면 됩니다.'
                    : '설정한 준비 시간은 ${_formatPrepTime(prepTimeMinutes!)}입니다.',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
