import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'first_login_prep_time_logic.dart';
import 'first_login_prep_time_styles.dart';
import '../home.dart';

// StatefulWidget은 화면 안의 값이 바뀔 수 있을 때 사용한다.
// 이 페이지는 입력값, 에러 메시지, 버튼 표시 여부가 계속 변하므로
// StatelessWidget이 아니라 StatefulWidget으로 만든다.
class FirstLoginPrepTimePage extends StatefulWidget {
  const FirstLoginPrepTimePage({super.key});

  @override
  // createState는 이 위젯이 사용할 실제 상태 객체를 만든다.
  State<FirstLoginPrepTimePage> createState() => _FirstLoginPrepTimePageState();
}

// State 클래스는 "변할 수 있는 값"과 "이벤트 처리"를 담당한다.
// widget 클래스는 비교적 고정된 껍데기이고,
// state 클래스가 실제 동작을 들고 있다고 이해하면 쉽다.
//
// 여기서는
// - 입력값 컨트롤러
// - 에러 메시지 상태
// - 사용자가 입력을 시작했는지 여부
// - 제출 버튼 동작
// 을 관리한다.
//
// 검증 규칙은 logic 파일로,
// 모양 관련 값은 styles 파일로 빼 두어서 역할을 분리했다.
class _FirstLoginPrepTimePageState extends State<FirstLoginPrepTimePage> {
  // TextEditingController는 TextField 안의 현재 텍스트를 읽고 바꾸는 도구다.
  // 단순 변수와 달리 TextField와 직접 연결되어 있어서
  // 코드에서 값을 바꾸면 화면도 같이 바뀐다.
  final TextEditingController prepTimeController = TextEditingController();

  // 입력창 decoration의 errorText에 연결되는 값이다.
  // null이면 에러가 없다는 뜻이고, 문자열이면 그 문구가 화면에 표시된다.
  String? prepTimeError;

  // 사용자가 한 번이라도 입력을 시작했는지 기록해서,
  // 첫 진입 직후에는 빈 값 오류를 바로 보여주지 않도록 제어한다.
  bool hasEditedPrepTime = false;

  @override
  void initState() {
    super.initState();

    // initState는 State가 처음 만들어질 때 한 번만 실행된다.
    // 여기서는 입력이 바뀔 때마다 검증을 다시 하도록 listener를 등록한다.
    prepTimeController.addListener(_handlePrepTimeChanged);
  }

  @override
  void dispose() {
    // controller, listener 같은 자원은 화면이 사라질 때 정리해야 한다.
    // dispose를 하지 않으면 메모리 누수나 예상치 못한 동작이 생길 수 있다.
    prepTimeController.removeListener(_handlePrepTimeChanged);
    prepTimeController.dispose();
    super.dispose();
  }

  // listener에서 호출되는 메서드다.
  // 현재 입력값을 읽어서 최신 에러 상태를 계산한다.
  void _handlePrepTimeChanged() {
    final input = prepTimeController.text.trim();

    // 화면 파일은 직접 규칙을 알지 않고,
    // logic 모듈에 "지금 값이 유효한가?"를 물어본다.
    final nextError = FirstLoginPrepTimeLogic.validatePrepTime(
      input,
      showEmptyMessage: hasEditedPrepTime,
    );

    // 이전 오류와 같으면 불필요한 rebuild를 막는다.
    if (prepTimeError == nextError) {
      return;
    }

    // setState를 호출하면 build가 다시 실행되고,
    // 바뀐 에러 문구나 버튼 표시 상태가 화면에 반영된다.
    setState(() {
      prepTimeError = nextError;
    });
  }

  // getter는 "계산된 값"을 읽기 좋은 형태로 꺼낼 때 유용하다.
  // build 안에서 긴 조건식을 매번 쓰는 대신 isPrepTimeValid만 읽으면 된다.
  bool get isPrepTimeValid {
    final input = prepTimeController.text.trim();

    // getter로 빼 두면 버튼 표시 조건을 build 안에서 읽기 쉬워진다.
    return FirstLoginPrepTimeLogic.isValidPrepTime(input);
  }

  // 하단 다음 버튼을 눌렀을 때 실행되는 메서드다.
  void submit() {
    final input = prepTimeController.text.trim();
    final validationError = FirstLoginPrepTimeLogic.validatePrepTime(
      input,
      showEmptyMessage: true,
    );
    final minutes = FirstLoginPrepTimeLogic.parsePrepTime(input);

    // 제출 시에도 같은 검증 함수를 재사용해서,
    // 화면 표시 조건과 실제 이동 조건이 서로 달라지지 않게 한다.
    if (validationError != null || minutes == null) {
      setState(() {
        hasEditedPrepTime = true;
        prepTimeError = validationError;
      });
      return;
    }

    // pushReplacement는 현재 페이지를 새 페이지로 "교체"한다.
    // 즉, 뒤로 가기를 눌렀을 때 이 설정 페이지로 다시 돌아오지 않게 할 때 자주 쓴다.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(prepTimeMinutes: minutes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FirstLoginPrepTimeStyles.pageBackgroundColor,

      // SafeArea는 상태바, 노치, 하단 시스템 영역과 겹치지 않게 해 준다.
      body: SafeArea(
        child: Padding(
          padding: FirstLoginPrepTimeStyles.pagePadding,

          // Container는 하나의 큰 카드 역할을 한다.
          // 배경색, 테두리, 둥근 모서리 같은 장식을 넣기 좋다.
          child: Container(
            width: double.infinity,
            padding: FirstLoginPrepTimeStyles.cardPadding,
            decoration: FirstLoginPrepTimeStyles.cardDecoration,

            // Column은 세로 방향으로 위젯을 차례대로 쌓는다.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 화면 상단의 라벨 배지
                Container(
                  padding: FirstLoginPrepTimeStyles.badgePadding,
                  decoration: FirstLoginPrepTimeStyles.badgeDecoration,
                  child: const Text(
                    '첫 로그인 설정',
                    style: FirstLoginPrepTimeStyles.badgeTextStyle,
                  ),
                ),

                // Spacer는 남는 공간을 차지해서
                // 위/아래 요소 사이 간격을 유연하게 만들어 준다.
                const Spacer(),

                // 메인 질문 제목
                const Text(
                  '준비시간이\n보통 얼마나 걸리나요?',
                  style: FirstLoginPrepTimeStyles.titleTextStyle,
                ),
                const SizedBox(height: 16),

                // 보조 설명 문구
                Text(
                  '외출 전 준비 시간을 입력해주시면 알람 시간을 더 정확하게 맞춰드릴게요.',
                  style: FirstLoginPrepTimeStyles.descriptionTextStyle(),
                ),
                const SizedBox(height: 32),

                // Row는 가로 방향 배치다.
                // 여기서는 "입력창 + 단위 텍스트"를 한 줄에 배치한다.
                Row(
                  children: [
                    // Expanded를 쓰면 남는 가로 공간을 입력창이 최대한 차지한다.
                    Expanded(
                      child: TextField(
                        controller: prepTimeController,

                        // 숫자 키패드가 뜨도록 요청한다.
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          // 숫자 이외의 문자는 입력 자체를 막는다.
                          FilteringTextInputFormatter.digitsOnly,

                          // 180을 넘는 값이 들어오면 자동으로 180으로 보정한다.
                          const MaxPrepTimeInputFormatter(),
                        ],
                        onChanged: (_) {
                          // 첫 입력이 발생하는 순간부터는 빈 값 오류를 보여줄 수 있게 한다.
                          if (!hasEditedPrepTime) {
                            setState(() {
                              hasEditedPrepTime = true;
                              prepTimeError =
                                  FirstLoginPrepTimeLogic.validatePrepTime(
                                    prepTimeController.text.trim(),
                                    showEmptyMessage: true,
                                  );
                            });
                          }
                        },
                        onSubmitted: (_) {
                          // 키보드의 완료 버튼을 눌렀을 때도 같은 제출 흐름을 사용한다.
                          if (isPrepTimeValid) {
                            submit();
                          }
                        },
                        style: FirstLoginPrepTimeStyles.inputTextStyle,
                        decoration:
                            FirstLoginPrepTimeStyles.prepTimeInputDecoration(
                              errorText: prepTimeError,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 사용자가 지금 어떤 단위를 입력 중인지 보여주는 보조 텍스트
                    const Text(
                      '분',
                      style: FirstLoginPrepTimeStyles.unitTextStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Wrap은 줄바꿈이 가능한 가로 배치다.
                // 버튼이 많아지면 자동으로 다음 줄로 넘겨서 보여주기 좋다.
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: FirstLoginPrepTimeLogic.quickSelectMinutes.map((
                    minutes,
                  ) {
                    return OutlinedButton(
                      onPressed: () {
                        setState(() {
                          hasEditedPrepTime = true;

                          // 빠른 선택 버튼도 동일한 입력 흐름을 타도록
                          // 컨트롤러 값만 바꿔서 listener가 함께 동작하게 한다.
                          prepTimeController.text = '$minutes';
                        });
                      },
                      style: FirstLoginPrepTimeStyles.quickSelectButtonStyle(),

                      // map으로 만든 각 숫자를 버튼 글자로 보여준다.
                      child: Text('$minutes분'),
                    );
                  }).toList(),
                ),
                const Spacer(),

                // AnimatedSwitcher는 child가 바뀔 때 자연스럽게 전환 애니메이션을 준다.
                // 여기서는 "안내 문구 <-> 다음 버튼"이 바뀔 때 부드럽게 보이게 한다.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),

                  // 유효성 검사를 통과했을 때만 다음 버튼을 보여준다.
                  child: isPrepTimeValid
                      ? SizedBox(
                          key: const ValueKey('next_button'),
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: submit,
                            style: FirstLoginPrepTimeStyles.nextButtonStyle(),

                            // const Text는 값이 변하지 않는 정적인 위젯이라
                            // rebuild 시에도 효율적으로 재사용될 수 있다.
                            child: const Text(
                              '다음',
                              style:
                                  FirstLoginPrepTimeStyles.nextButtonTextStyle,
                            ),
                          ),
                        )
                      : Text(
                          key: const ValueKey('next_hint'),

                          // 버튼 대신 보여주는 안내 문구
                          '올바른 준비 시간을 입력하면 다음 버튼이 나타나요.',
                          style: FirstLoginPrepTimeStyles.nextHintTextStyle(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
