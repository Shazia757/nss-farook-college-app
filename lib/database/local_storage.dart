import 'dart:developer';
import 'package:get_storage/get_storage.dart';
import 'package:nss_new/model/user_model.dart';

class LocalStorage {
  static final _box = GetStorage();

  static bool get isLoggedIn {
    final hasFlag = _box.read('isLoggedIn') ?? false;
    final token = _box.read('token');
    final user = _box.read('user');
    return hasFlag == true &&
        token != null &&
        token.toString().isNotEmpty &&
        user != null;
  }

  void writeSession({
    required Users user,
    required String token,
    String? role,
  }) {
    try {
      _box.write('user', user.toJson());
      _box.write('token', token);
      final resolvedRole = role ?? user.role ?? 'vol';
      _box.write('role', resolvedRole);
      _box.write('isLoggedIn', true);
    } catch (e) {
      log('Error writing session: $e');
    }
  }

  void writeRole(String role) {
    try {
      _box.write('role', role);
    } catch (e) {
      log(e.toString());
    }
  }

  String readRole() {
    try {
      final role = _box.read('role');
      if (role != null && role.toString().isNotEmpty) {
        return role.toString();
      }
      final user = readUser();
      return user.role ?? 'vol';
    } catch (e) {
      log(e.toString());
      return 'vol';
    }
  }

  void writeUser(Users user) {
    try {
      _box.write('user', user.toJson());
      if (user.role != null && user.role!.isNotEmpty) {
        _box.write('role', user.role);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void writeToken(String toc) {
    try {
      _box.write('token', toc);
      if (toc.isNotEmpty) {
        _box.write('isLoggedIn', true);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  String? get currentToken => _box.read('token');

  Future<String?> readToken() async {
    try {
      final token = _box.read('token');
      return token?.toString();
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Users readUser() {
    try {
      final data = _box.read('user');
      if (data != null && data is Map<String, dynamic>) {
        return Users.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    }
    return Users();
  }

  void clearAll() {
    try {
      _box.erase();
    } catch (e) {
      log('Error clearing LocalStorage: $e');
    }
  }

  void saveVolunteerEnrollment(
    String admissionNo,
    int programId,
    DateTime enrollmentDate,
  ) {
    try {
      final key = 'enrollments_$admissionNo';
      final dynamic raw = _box.read(key);
      final Map<String, dynamic> enrollments = raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{};
      enrollments[programId.toString()] = enrollmentDate
          .toUtc()
          .toIso8601String();
      _box.write(key, enrollments);
    } catch (e) {
      log('Error saving volunteer enrollment: $e');
    }
  }

  void removeVolunteerEnrollment(String admissionNo, int programId) {
    try {
      final key = 'enrollments_$admissionNo';
      final dynamic raw = _box.read(key);
      if (raw is Map) {
        final Map<String, dynamic> enrollments = Map<String, dynamic>.from(raw);
        enrollments.remove(programId.toString());
        _box.write(key, enrollments);
      }
    } catch (e) {
      log('Error removing volunteer enrollment: $e');
    }
  }

  Map<int, DateTime> getVolunteerEnrollments(String admissionNo) {
    try {
      final key = 'enrollments_$admissionNo';
      final dynamic raw = _box.read(key);
      if (raw is Map) {
        final Map<int, DateTime> result = {};
        raw.forEach((k, v) {
          final pid = int.tryParse(k.toString());
          final dt = DateTime.tryParse(v.toString());
          if (pid != null && dt != null) {
            result[pid] = dt.toUtc();
          }
        });
        return result;
      }
    } catch (e) {
      log('Error reading volunteer enrollments: $e');
    }
    return {};
  }

  void saveServerClockOffset(Duration offset) {
    try {
      _box.write('server_clock_offset_ms', offset.inMilliseconds);
    } catch (e) {
      log('Error saving server clock offset: $e');
    }
  }

  DateTime getEstimatedServerTime() {
    try {
      final offsetMs = _box.read('server_clock_offset_ms');
      final nowUtc = DateTime.now().toUtc();
      if (offsetMs is int) {
        return nowUtc.add(Duration(milliseconds: offsetMs));
      }
      return nowUtc;
    } catch (e) {
      return DateTime.now().toUtc();
    }
  }
}
