import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  List<String> _userRights = [];
  List<int> _userRoleIds = [];
  bool _isAdmin = false;

  // Getter to access rights if needed for debugging or other purposes
  List<String> get userRights => _userRights;
  List<int> get userRoleIds => _userRoleIds;
  bool get isAdmin => _isAdmin;

  /// Loads permissions from SharedPreferences on app startup.
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. Try loading from specific tokenInfo key
    String? tokenInfoString = prefs.getString('tokenInfo');
    if (tokenInfoString != null) {
      try {
        Map<String, dynamic> tokenInfo = jsonDecode(tokenInfoString);
        _parseAndSetData(tokenInfo);
        print(
            'DEBUG: Permissions Loaded from tokenInfo: ${_userRights} rights found. Roles: $_userRoleIds');
        return;
      } catch (e) {
        print('Error parsing tokenInfo: $e');
      }
    }

    // 2. Fallback: Try loading from userData (Legacy/Root object)
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      print('DEBUG: tokenInfo missing, checking userData...');
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        // Print keys to help user debug where rights might be
        print('DEBUG: userData Keys: ${userData.keys.toList()}');

        // Pass the whole object to parser, it will look for keys
        _parseAndSetData(userData);
      } catch (e) {
        print('Error parsing userData: $e');
        _reset();
      }
    } else {
      print('DEBUG: No tokenInfo OR userData found in storage.');
      _reset();
    }
  }

  void _reset() {
    _userRights = [];
    _userRoleIds = [];
    _isAdmin = false;
  }

  /// Checks if the user has the specified permission.
  /// Accepts either String or int ID.
  bool isGranted(dynamic permissionId) {
    // ID -1 is used for "Always Visible" (e.g. Module Headers that verify children internally)
    if (permissionId == -1) {
      return true;
    }

    // Admin Override: If user is Admin (Role ID 2 or Name 'Admin'), grant everything
    if (_isAdmin) {
      return true;
    }

    return _userRights.contains(permissionId.toString());
  }

  /// Checks if ANY of the provided permissions are granted.
  /// Used for grouping headers (e.g. Show "Sales" if user has "Invoice" OR "Order").
  bool hasAny(List<dynamic> permissionIds) {
    if (_isAdmin) return true; // Admin sees all groups
    if (permissionIds.isEmpty) return false;
    for (var id in permissionIds) {
      if (isGranted(id)) return true;
    }
    return false;
  }

  /// Saves the tokenInfo object to SharedPreferences and updates the in-memory rights list.
  Future<void> savePermissions(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // We expect the caller to have saved userData/tokenInfo string already,
    // but we refresh memory here.
    // However, if strict 'tokenInfo' saving is needed, we should save it:
    if (data.containsKey('tokenInfo')) {
      await prefs.setString('tokenInfo', jsonEncode(data['tokenInfo']));
    } else {
      // Save entire data blob as tokenInfo to be safe if rights are at root
      await prefs.setString('tokenInfo', jsonEncode(data));
    }

    _parseAndSetData(data);
  }

  /// Clears stored permissions and resets the in-memory rights list.
  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('tokenInfo');
    // We don't remove userData here usually as it might store other session info,
    // but if full logout, the caller handles that.
    _reset();
  }

  /// Helper to parse rights AND roles from the data map.
  void _parseAndSetData(Map<String, dynamic> data) {
    // 1. RIGHTS PARSING
    // Check for 'rights' at root or inside 'tokenInfo'
    List<dynamic>? rightsList;
    if (data['rights'] != null) {
      rightsList = data['rights'];
    } else if (data['tokenInfo'] != null &&
        data['tokenInfo']['rights'] != null) {
      rightsList = data['tokenInfo']['rights'];
    }

    if (rightsList != null) {
      try {
        _userRights =
            (rightsList).map((e) => e['right_ID'].toString()).toList();
        print('DEBUG: Extracted ${_userRights.length} permissions.');
      } catch (e) {
        print('Error extracting rights: $e');
        _userRights = [];
      }
    } else {
      _userRights = [];
    }

    // 2. ROLES PARSING
    // Check for 'roles' at root or inside 'tokenInfo'
    List<dynamic>? rolesList;
    if (data['roles'] != null) {
      rolesList = data['roles'];
    } else if (data['tokenInfo'] != null &&
        data['tokenInfo']['roles'] != null) {
      rolesList = data['tokenInfo']['roles'];
    }

    _userRoleIds = [];
    _isAdmin = false;

    if (rolesList != null) {
      try {
        for (var role in rolesList) {
          int rId = role['role_ID'] is int
              ? role['role_ID']
              : int.tryParse(role['role_ID'].toString()) ?? 0;
          _userRoleIds.add(rId);

          // Check for Admin (ID 2 or Name 'Admin')
          String rName = role['name']?.toString().toLowerCase() ?? '';
          if (rId == 2 || rName == 'admin') {
            _isAdmin = true;
          }
        }
        print('DEBUG: Extracted Roles: $_userRoleIds, IsAdmin: $_isAdmin');
      } catch (e) {
        print('Error extracting roles: $e');
      }
    }
  }
}
