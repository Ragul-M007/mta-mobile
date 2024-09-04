// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mta/models/AllTeamsRes.dart';
import 'package:mta/models/DashboardRes.dart';

class ChipsWidget extends StatefulWidget {
  List<AllTeamsData>? teams;
  final void Function(AllTeamsData) onDeleted;
  List<Data>? projects;
  final void Function(Data) onDeletedProject;
  List<String>? mails;
  final void Function(String) onDeletedMail;

  ChipsWidget(
      {Key? key,
      required this.teams,
      required this.onDeleted,
      required this.projects,
      required this.onDeletedProject,
      required this.mails,
      required this.onDeletedMail})
      : super(key: key);

  @override
  State<ChipsWidget> createState() => _ChipsWidgetState();
}

class _ChipsWidgetState extends State<ChipsWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          widget.teams!.isNotEmpty
              ? Wrap(
                  spacing: 10.0, // Adjust spacing between chips
                  children: widget.teams!
                      .map((chipText) => Chip(
                          onDeleted: () => widget.onDeleted(chipText),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                50.0), // Custom border radius
                          ),
                          deleteIcon: Icon(
                            Icons.close_outlined,
                            size: 16,
                          ),
                          backgroundColor: Colors.white,
                          label: Text(chipText.teamName!,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.5))))
                      .toList(),
                )
              : widget.projects!.isNotEmpty
                  ? Wrap(
                      spacing: 10.0, // Adjust spacing between chips
                      children: widget.projects!
                          .map((chipText) => Chip(
                              onDeleted: () =>
                                  widget.onDeletedProject(chipText),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    50.0), // Custom border radius
                              ),
                              deleteIcon: Icon(
                                Icons.close_outlined,
                                size: 16,
                              ),
                              backgroundColor: Colors.white,
                              label: Text(chipText.projectName!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.5))))
                          .toList(),
                    )
                  : Wrap(
                      spacing: 10.0, // Adjust spacing between chips
                      children: widget.mails!
                          .map((chipText) => Chip(
                              onDeleted: () => widget.onDeletedMail(chipText),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    50.0), // Custom border radius
                              ),
                              deleteIcon: Icon(
                                Icons.close_outlined,
                                size: 16,
                              ),
                              backgroundColor: Colors.white,
                              label: Text(chipText,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.5))))
                          .toList(),
                    ),
        ],
      ),
    );
  }
}
