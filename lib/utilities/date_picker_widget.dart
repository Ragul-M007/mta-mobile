import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/utilities/customcolor.dart';

class DatePickerWidget extends StatefulWidget {
  String? hintText;
  final Function(DateTime) onDateSelected;
  DatePickerWidget(
      {super.key, required this.hintText, required this.onDateSelected});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? picked;

  TextEditingController _dateController = TextEditingController();

  DateFormat df3 = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _selectDate();
      },
      child: TextField(
        controller: _dateController,
        enabled: false,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: CustomColors.fontColor),
          suffixIcon:
              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  _selectDate() async {
    picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),

      /// Restricted to 180 days
      lastDate: DateTime.now().add(const Duration(days: 36500)),
    );
    if (picked != null) {
      widget.onDateSelected(picked!);
      var dateFormate =
          df3.format((DateFormat("yyyy-MM-dd hh:mm").parse(picked.toString())));
      _dateController.text = dateFormate;
    }
  }
}
