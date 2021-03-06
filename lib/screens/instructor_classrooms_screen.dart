import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/instructor_classrooms.dart';
import '../providers/auth.dart';

import '../models/instructor_classroom.dart';
import '../models/instructor_student.dart';

import '../components/general_app_drawer.dart';

import './create_classroom_screen.dart';
import './instructor_classroom_details/instructor_classroom_details_screen.dart';

class InstructorClassroomsScreen extends StatefulWidget {
  @override
  _InstructorClassroomsScreenState createState() =>
      _InstructorClassroomsScreenState();
}

class _InstructorClassroomsScreenState
    extends State<InstructorClassroomsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<InstructorClassrooms>(context, listen: false)
          .getUserIdAndNameAndEmailAndClassroomsReferences();
      Provider.of<InstructorClassrooms>(context, listen: false)
          .fetchClassrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double sh = screenSize.height;
    double sw = screenSize.width;

    return Scaffold(
      drawer: GeneralAppDrawer(
        userType: "instructor",
      ),
      appBar: AppBar(
        elevation: 1.5,
        title: Text(
          'Attend KWASU',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(CreateClassroomScreen.routeName);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Selector<InstructorClassrooms, bool>(
        selector: (_, instructor) => instructor.classroomsLoading,
        shouldRebuild: (_, __) => true,
        builder: (_, classroomsLoading, __) {
          print(classroomsLoading);

          if (classroomsLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Stream<InstructorClassroom>> _classrooms =
                Provider.of<InstructorClassrooms>(context, listen: false)
                    .classrooms;
            if (_classrooms == null || _classrooms.isEmpty) {
              return Center(
                child: Text('No classrooms yet...'),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(0.04 * sw),
              itemCount: _classrooms.length,
              itemBuilder: (_, index) {
                return StreamBuilder<InstructorClassroom>(
                    stream: _classrooms[index],
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        InstructorClassroom classroom = snapshot.data;

                        return StreamBuilder<List<InstructorStudent>>(
                          stream: classroom.students,
                          builder: (_, snapshot) {
                            List<InstructorStudent> students = snapshot.data;

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  InstructorClassroomDetailsScreen.routName,
                                  arguments: [
                                    _classrooms[index],
                                    classroom,
                                    students,
                                  ],
                                );
                              },
                              child: AspectRatio(
                                aspectRatio: 2.5 / 1.0,
                                child: Container(
                                  width: double.maxFinite,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9.0),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          'assets/images/classroom_cover.jpg'),
                                    ),
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        top: 18.0,
                                        left: 14.0,
                                        child: Text(
                                          classroom.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12.0,
                                        left: 14.0,
                                        child: Text(
                                          snapshot.hasData
                                              ? '${students.length} students'
                                              : 'Loading students...',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10.0,
                                        right: 0.0,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    });
              },
              separatorBuilder: (_, index) {
                return const SizedBox(height: 10.0);
              },
            );
          }
        },
      ),
    );
  }
}
