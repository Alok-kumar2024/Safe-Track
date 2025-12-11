import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/state/profile_provider.dart';

// removing the error thing from here , means commenting them...
class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    required this.hint,
    required this.hintColor,
    required this.radius,
    required this.filled,
    required this.filledColor,
    required this.tec,
    required this.paddingHorizontal,
    required this.fW,
    this.keyboard,
    required this.enabledColorBorder,
    required this.focusedColorBorder,
    // required this.node,
    // required this.isError,
    // required this.index,
  });

  final String hint;
  final Color hintColor;
  final double radius;
  final bool filled ;
  final Color filledColor;
  final double paddingHorizontal;
  final TextEditingController tec;
  final Color enabledColorBorder;
  final FontWeight fW;
  TextInputType? keyboard = TextInputType.text;
  final Color focusedColorBorder;
  // final FocusNode node;
  // final bool isError;
  // final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: TextField(
        style: TextStyle(fontSize: 15),
        // focusNode: node,
        // onChanged: (value)
        // {
        //   if(value.isNotEmpty && isError)
        //     {
        //       context.read<ProfileProvider>().modifyErrorList(index, false);
        //     }
        // },
        textAlign: TextAlign.justify,
        controller: tec,
        keyboardType: keyboard,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          filled: filled,
          fillColor: filledColor,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                // isError ?Colors.red :
                enabledColorBorder),
            borderRadius: BorderRadius.circular(radius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                // isError ? Colors.red :
                focusedColorBorder,width:2),
            borderRadius: BorderRadius.circular(radius),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: hintColor,fontWeight: fW),
        ),
      ),
    );
  }
}
