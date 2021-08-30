import 'package:flutter/material.dart';

class OnScreenKeyboard extends StatelessWidget {
  OnScreenKeyboard({
    required this.controller,
    Key? key,
    this.onTextInput,
    this.onBackspace,
  }) : super(key: key);

  final TextEditingController controller;
  final ValueSetter<String>? onTextInput;
  final VoidCallback? onBackspace;

  void _textInputHandler(String text) {
    _insertText(text);
    onTextInput?.call(text);
  }

  void _backspaceHandler() {
    _backspace();
    onBackspace?.call();
  }

  void _spacebarHandler() {
    _insertText(' ');
  }

  void _clearHandler() {
    _clear();
  }

  void _initEditingControllerSelection() {
    if (controller.selection.start == -1) {
      controller.selection = controller.selection.copyWith(baseOffset: 0, extentOffset: 0);
    }
  }

  void _insertText(String myText) {
    _initEditingControllerSelection();
    final text = controller.text;
    final textSelection = controller.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void _backspace() {
    _initEditingControllerSelection();
    final text = controller.text;
    final textSelection = controller.selection;
    final selectionLength = textSelection.end - textSelection.start;

    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      controller.text = newText;
      controller.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }

    // Delete the previous character
    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  void _clear() {
    _initEditingControllerSelection();
    controller.clear();
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  final List<String> keylist = List<String>.generate(36, (int index) {
    if (index <= 25) {
      return String.fromCharCode(index + 65);
    } else if (index > 25 && index <= 36) {
      return (index - 26).toString();
    }
    return '';
  });

  //1-35 (A-Z,0-9), 36 (Clear), 37 (Space), 38 (Backspace)
  Widget buildInputKey(int index) {
    if (index <= 35) {
      var text = keylist[index];
      return TextKey(
        text: text,
        onTextInput: _textInputHandler,
      );
    } else if (index == 36) {
      return ClearKey(
        onClear: _clearHandler,
      );
    } else if (index == 37) {
      return SpaceKey(
        onSpace: _spacebarHandler,
      );
    } else if (index == 38) {
      return BackspaceKey(
        onBackspace: _backspaceHandler,
      );
    }
    return Container();
  }

  List<Widget> buildKeyboardRow(int startIndex, int endIndex) {
    List<Widget> inputKeys =
        List<Widget>.generate(endIndex - startIndex, (index) => buildInputKey(startIndex + index));
    return inputKeys;
  }

  @override
  Widget build(BuildContext context) {
    // return GridView.builder(
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 9,
    //       mainAxisSpacing: 5,
    //       crossAxisSpacing: 5,
    //     ),
    //     itemCount: 39,
    //     itemBuilder: (context, index) {
    //       if(index <= 35) {
    //         var text = keylist[index];
    //         return TextKey(
    //           text: text,
    //           onTextInput: _textInputHandler,
    //         );
    //       } else if (index == 36) {
    //         return BackspaceKey(
    //           onBackspace: _backspaceHandler,
    //         );
    //       } else if (index == 37) {
    //         return BackspaceKey(
    //           onBackspace: _backspaceHandler,
    //         );
    //       } else if (index == 38) {
    //         return BackspaceKey(
    //           onBackspace: _backspaceHandler,
    //         );
    //       }
    //       return Container();
    //     },
    //   );

    return Container(
      height: 160,
      //color: Colors.,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: buildKeyboardRow(0, 9),
            ),
          ),
          Expanded(
            child: Row(
              children: buildKeyboardRow(9, 18),
            ),
          ),
          Expanded(
            child: Row(
              children: buildKeyboardRow(18, 27),
            ),
          ),
          Expanded(
            child: Row(
              children: buildKeyboardRow(27, 36),
            ),
          ),
          Expanded(
            child: Row(
              children: buildKeyboardRow(36, 39),
            ),
          ),
        ],
      ),
    );
  }
}

class TextKey extends StatelessWidget {
  const TextKey({
    Key? key,
    required this.text,
    required this.onTextInput,
    this.flex = 1,
  }) : super(key: key);

  final String text;
  final ValueSetter<String> onTextInput;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: Colors.black12,
          child: InkWell(
            onTap: () {
              onTextInput?.call(text.toLowerCase());
            },
            child: Container(
              child: Center(child: Text(text)),
            ),
          ),
        ),
      ),
    );
  }
}

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({
    Key? key,
    required this.onBackspace,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback onBackspace;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: Colors.black12,
          child: InkWell(
            onTap: () {
              onBackspace?.call();
            },
            child: Container(
              child: Center(
                child: Icon(Icons.backspace),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClearKey extends StatelessWidget {
  const ClearKey({
    Key? key,
    required this.onClear,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback onClear;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: Colors.black12,
          child: InkWell(
            onTap: () {
              onClear?.call();
            },
            child: Container(
              child: Center(
                child: Icon(Icons.delete),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SpaceKey extends StatelessWidget {
  const SpaceKey({
    Key? key,
    required this.onSpace,
    this.flex = 1,
  }) : super(key: key);

  final VoidCallback onSpace;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: Colors.black12,
          child: InkWell(
            onTap: () {
              onSpace?.call();
            },
            child: Container(
              child: Center(
                child: Icon(Icons.space_bar),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
