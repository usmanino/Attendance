import 'dart:io';

import 'package:attend/screens/splash_screen.dart';
import 'package:attend/screens/student_classrooms_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/auth.dart';
import '../providers/instructor_classrooms.dart';
import '../providers/student_classrooms.dart';

import '../components/custom_dialog.dart';

import '../utils/excel/create_excel.dart';

class GeneralAppDrawer extends StatelessWidget {
  const GeneralAppDrawer({
    Key key,
    @required this.userType,
  }) : super(key: key);

  final String userType;

  @override
  Widget build(BuildContext context) {
    dynamic profile = userType == "instructor"
        ? Provider.of<InstructorClassrooms>(context, listen: true)
        : Provider.of<StudentClassrooms>(context, listen: true);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DrawerHeader(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return PhotoDialog(
                                staticProfile: profile,
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            image: DecorationImage(
                              image: profile.photo == null
                                  ? AssetImage('assets/images/profile.png')
                                  : CachedNetworkImageProvider(
                                      profile.photo,
                                    ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      profile.name,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                "Classes",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.map, color: Colors.white),
            //   title: Text(
            //     "View Map",
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => MapPage()));
            //   },
            // ),
            if (userType != "instructor")
              ListTile(
                leading: Icon(Icons.note_alt_outlined, color: Colors.white),
                title: Text(
                  "About",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SplashScreen()));
                },
              ),
            if (userType == "instructor")
              ////    Where Excel sheets get exported   ////
              ExportExcel(),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              title: Text(
                "Sign out",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Provider.of<Auth>(context, listen: false).logout();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExportExcel extends StatefulWidget {
  const ExportExcel({
    Key key,
  }) : super(key: key);

  @override
  _ExportExcelState createState() => _ExportExcelState();
}

class _ExportExcelState extends State<ExportExcel> {
  bool exporting = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.file_download, color: Colors.white),
      title: Text(
        "Export ",
        style: TextStyle(color: Colors.white),
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(8.0),
        child: exporting
            ? CircularProgressIndicator()
            : Image.asset('assets/images/ms_excel_icon.png'),
      ),
      onTap: () async {
        setState(() {
          this.exporting = true;
        });

        String path;

        try {
          path = await exportClassroomsToExcel(
              Provider.of<Auth>(context, listen: false).userId);

          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (ctx) => CustomDialog(
              title: "Excel saved to:",
              description: path,
              positiveButtonText: "Okay",
              negativeButtonText: null,
            ),
          );
        } catch (error) {
          showErrorDialog(context, error.toString());
        }

        setState(() {
          this.exporting = false;
        });
      },
    );
  }
}

class PhotoDialog extends StatelessWidget {
  final dynamic staticProfile;

  const PhotoDialog({@required this.staticProfile});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                try {
                  File photo = await ImagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 400,
                    maxHeight: 400,
                  );

                  Navigator.of(context).pop();

                  if (photo != null) await staticProfile.uploadPhoto(photo);
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.maxFinite,
                child: Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                try {
                  File photo = await ImagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 400,
                    maxHeight: 400,
                  );

                  Navigator.of(context).pop();

                  if (photo != null) await staticProfile.uploadPhoto(photo);
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: double.maxFinite,
                child: Text(
                  'Choose Photo',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
