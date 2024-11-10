import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class OtpForm extends StatefulWidget {
  const OtpForm({
    super.key,
    required this.callBack,
  });
  
  final Function(String) callBack;

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  
  void _onChanged(int index) {
    setState(() {
      // Check if all fields are filled
      if (_controllers.every((controller) => controller.text.isNotEmpty)) {
        widget.callBack(_controllers.map((controller) => controller.text).join());
      } else {
        // Do nothing while typing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: RawKeyboardListener(
        autofocus: true, // Allow RawKeyboardListener to capture keyboard events
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
            FocusScope.of(context).previousFocus();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              height: 20,
              width: 20,
              child: TextFormField(
                autofocus: index == 0,  // Only autofocus on the first input
                controller: _controllers[index],
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    FocusScope.of(context).nextFocus(); // Move to next field
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus(); // Move to previous field
                  }
                  _onChanged(index);  // Update callback only when all fields are filled
                },
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: const InputDecoration(counterText: ""),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ),
    );
  }
}