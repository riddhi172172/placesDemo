import 'package:flutter/material.dart';

class AlertMessageDialog extends StatefulWidget {

  final String text;

  AlertMessageDialog({Key key, @required this.text}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AlertMessageDialogState();
}

class AlertMessageDialogState extends State<AlertMessageDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(widget.text,style: TextStyle(fontSize: 17),),
            ),
          ),
        ),
      ),
    );
  }
}