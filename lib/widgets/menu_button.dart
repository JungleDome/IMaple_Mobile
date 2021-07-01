import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  ButtonStyle? style;
  void Function()? onPressed;
  void Function()? onLongPress;
  String text;
  Icon? icon;

  MenuButton({
    Key? key,
    void Function()? this.onPressed,
    void Function()? this.onLongPress,
    ButtonStyle? this.style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    String this.text = '',
    Icon? this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: this.style ??
          TextButton.styleFrom(
            primary: Colors.black,
            alignment: Alignment.center,
            textStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
      onLongPress: this.onLongPress,
      onPressed: this.onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        //color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              this.icon ?? Container(),
              Text(this.text, style: Theme.of(context).textTheme.headline6),
            ],
          ),
        ),
      ),
    );
  }
}
