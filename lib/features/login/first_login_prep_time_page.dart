import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'first_login_prep_time_logic.dart';
import 'first_login_prep_time_styles.dart';
import 'login_service.dart';
import '../home.dart';

/*
==================================
**FirstLoginPrepTimePage Class**
==================================
*/
class FirstLoginPrepTimePage extends StatefulWidget {
  const FirstLoginPrepTimePage({super.key});

  @override
  // createState는 이 위젯이 사용할 실제 상태 객체를 만든다.
  State<FirstLoginPrepTimePage> createState() => _FirstLoginPrepTimePageState();
}

/*
=====================================
**_FirstLoginPrepTimePageState Class**
=====================================
*/
class _FirstLoginPrepTimePageState extends State<FirstLoginPrepTimePage> {
  final TextEditingController prepTimeController = TextEditingController();
  String? prepTimeError;
  bool hasEditedPrepTime = false;
  final LoginService _loginService = LoginService();

  @override
  void initState() {
    super.initState();
    prepTimeController.addListener(_handlePrepTimeChanged);
  }

  @override
  void dispose() {
    prepTimeController.removeListener(_handlePrepTimeChanged);
    prepTimeController.dispose();
    _loginService.dispose();
    super.dispose();
  }

  void _handlePrepTimeChanged() {
    final input = prepTimeController.text.trim();
    final nextError = FirstLoginPrepTimeLogic.validatePrepTime(
      input,
      showEmptyMessage: hasEditedPrepTime,
    );

    if (prepTimeError == nextError) {
      return;
    }

    setState(() {
      prepTimeError = nextError;
    });
  }

  bool get isPrepTimeValid {
    final input = prepTimeController.text.trim();

    return FirstLoginPrepTimeLogic.isValidPrepTime(input);
  }

  Future<void> submit() async {
    final input = prepTimeController.text.trim();
    final validationError = FirstLoginPrepTimeLogic.validatePrepTime(
      input,
      showEmptyMessage: true,
    );
    final minutes = FirstLoginPrepTimeLogic.parsePrepTime(input);

    if (validationError != null || minutes == null) {
      setState(() {
        hasEditedPrepTime = true;
        prepTimeError = validationError;
      });
      return;
    }

    final result = await _loginService.setPrepTime(minutes: minutes);

    if (!result.isSuccess) {
      setState(() {
        prepTimeError = result.message;
      });
      return;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(prepTimeMinutes: minutes)),
      );
    }
  }

  //아래부터 위젯이라 볼 필요 없음
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FirstLoginPrepTimeStyles.pageBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: FirstLoginPrepTimeStyles.pagePadding,

          child: Container(
            width: double.infinity,
            padding: FirstLoginPrepTimeStyles.cardPadding,
            decoration: FirstLoginPrepTimeStyles.cardDecoration,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: FirstLoginPrepTimeStyles.badgePadding,
                  decoration: FirstLoginPrepTimeStyles.badgeDecoration,
                  child: const Text(
                    '첫 로그인 설정',
                    style: FirstLoginPrepTimeStyles.badgeTextStyle,
                  ),
                ),

                const Spacer(),

                const Text(
                  '준비시간이\n보통 얼마나 걸리나요?',
                  style: FirstLoginPrepTimeStyles.titleTextStyle,
                ),
                const SizedBox(height: 16),

                Text(
                  '외출 전 준비 시간을 입력해주시면 알람 시간을 더 정확하게 맞춰드릴게요.',
                  style: FirstLoginPrepTimeStyles.descriptionTextStyle(),
                ),
                const SizedBox(height: 32),

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
