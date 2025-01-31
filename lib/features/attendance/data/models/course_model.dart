import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  CourseModel({
    required String courseId,
    required String courseName,
  }) : super(courseId: courseId, courseName: courseName);

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      courseId: map['courseId'],
      courseName: map['courseName'],
    );
  }
}
