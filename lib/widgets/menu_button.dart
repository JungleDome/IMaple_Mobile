import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  ButtonStyle? style;
  void Function()? onPressed;
  void Function()? onLongPress;
  String text;
  String subText;
  Icon? icon;

  Color textColor;
  Color boxColor;

  MenuButton({
    Key? key,
    this.onPressed,
    this.onLongPress,
    this.style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    this.text = '',
    this.subText = '',
    this.icon,
    this.textColor = Colors.white,
    this.boxColor = Colors.deepOrange,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: this.style ??
          TextButton.styleFrom(
            primary: textColor,
            alignment: Alignment.center,
            textStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
      onLongPress: this.onLongPress,
      onPressed: this.onPressed,
      child: Container(
        decoration: BoxDecoration(
          //border: Border.all(),
          color: boxColor,
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              // Add one stop for each color
              // Values should increase from 0.0 to 1.0
              stops: [0.1, 0.4, 0.5, 0.6, 1.0],
              colors: [boxColor, Color.lerp(boxColor, Colors.white, 0.1)!, Color.lerp(boxColor, Colors.white, 0.2)!, Color.lerp(boxColor, Colors.white, 0.1)!, boxColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 10.0),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        //color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              this.icon ?? Container(),
              Text(
                this.text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w100,
                    ),
              ),
              Visibility(
                visible: this.subText != '',
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
              ),
              Visibility(
                visible: this.subText != '',
                child: Text(
                  this.subText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
