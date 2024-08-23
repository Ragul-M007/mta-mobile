import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/customcolor.dart';

class TimerPickerWidget extends StatefulWidget {
  DateTime selectedDate;
  bool isDateSelected;
  final Function(DateTime) onSelectedFromTime;
  final Function(DateTime) onSelectedToTime;
  TimerPickerWidget(
      {super.key,
      required this.selectedDate,
      required this.isDateSelected,
      required this.onSelectedFromTime,
      required this.onSelectedToTime});

  @override
  State<TimerPickerWidget> createState() => _TimerPickerWidgetState();
}

class _TimerPickerWidgetState extends State<TimerPickerWidget> {
  TextEditingController endTimeController = TextEditingController();

  TextEditingController startTimeController = TextEditingController();

  TimeOfDay? choosenFromTime;
  final now = DateTime.now();

  TimeOfDay? choosenToTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: GestureDetector(
            onTap: () {
              if (widget.isDateSelected) {
                _selectFromTime();
              } else {
                AppUtils.showToastError("Date should be select before time");
              }
            },
            child: TextField(
              controller: startTimeController,
              enabled: false,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.all(15),
                hintText: "Select Time",
                hintStyle: TextStyle(color: CustomColors.fontColor),
                suffixIcon: Icon(
                  Icons.schedule,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (choosenFromTime != null) {
                  _selecttoTime();
                } else {
                  AppUtils.showToastError("Please select the start time");
                }
              });
            },
            child: TextField(
              controller: endTimeController,
              enabled: false,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.all(15),
                hintText: "Select Time",
                hintStyle: TextStyle(color: CustomColors.fontColor),
                suffixIcon: Icon(
                  Icons.schedule,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _selectFromTime() async {
    choosenFromTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      confirmText: "CONFIRM",
      helpText: "SELECT TIME",
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, textScaler: TextScaler.linear(1)),
          child: child!,
        );
      },
    );

    if (choosenFromTime != null) {
      setState(() {
        var currDate = DateTime.now();
        var currDateTime = "${currDate.day}-${currDate.month}-${currDate.year}";

        var date1 =
            "${widget.selectedDate.day}-${widget.selectedDate.month}-${widget.selectedDate.year}";
        var startShift = DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            choosenFromTime!.hour,
            choosenFromTime!.minute);
        final endShift =
            DateTime(now.year, now.month, now.day, now.hour, now.minute);
        if (widget.isDateSelected && date1 == currDateTime) {
          if (endTimeController.text == "") {
            if (startShift.isAfter(endShift)) {
              startTimeController.text = choosenFromTime!.format(context);
              widget.onSelectedFromTime(startShift);
            } else {
              AppUtils.showToastError(
                "Meetings can only be scheduled for future dates and times",
              );
              startTimeController.text = "";
            }
          } else {
            ///To check selected time is greater than the current time
            if (startShift.isAfter(endShift)) {
              startTimeController.text = choosenFromTime!.format(context);
              widget.onSelectedFromTime(startShift);
            } else if (!startShift.isAfter(endShift)) {
              AppUtils.showToastError(
                "Meetings can only be scheduled for future dates and timese",
              );
            } else {
              AppUtils.showToastError("Time should not be above the to time");
              startTimeController.text = "";
            }
          }
        } else {
          startTimeController.text = choosenFromTime!.format(context);
          widget.onSelectedFromTime(startShift);
        }
      });
    }
  }

  _selecttoTime() async {
    choosenToTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      confirmText: "CONFIRM",
      // cancelText: "NOT NOW",
      helpText: "SELECT TIME",
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, textScaler: TextScaler.linear(1)),
          child: child!,
        );
      },
    );
    if (choosenFromTime == null) {
      AppUtils.showToastError("Select start time");
      return;
    }
    if (choosenToTime != null) {
      setState(() {
        var time = DateTime.now();
        var startShift = DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            choosenToTime!.hour,
            choosenToTime!.minute);
        if (choosenFromTime == null) {
          choosenFromTime = TimeOfDay.fromDateTime(DateTime(
              time.year,
              time.month,
              time.day,
              choosenFromTime!.hour,
              choosenFromTime!.minute));
        }
        var t2 = choosenFromTime;
        final endShift = DateTime(
            widget.selectedDate.year,
            widget.selectedDate.month,
            widget.selectedDate.day,
            t2!.hour,
            t2.minute + 29);
        if (choosenFromTime!.format(context) ==
            choosenToTime!.format(context)) {
          AppUtils.showToastError("The from and to time should not be same");
        } else if (startShift.isAfter(endShift)) {
          endTimeController.text = choosenToTime!.format(context);
          widget.onSelectedToTime(startShift);
        } else {
          AppUtils.showToastError(
              "The minimum time must be greater than 30 minutes.");
        }
      });
    }
  }
}
