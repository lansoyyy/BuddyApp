import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._internal();

  static final GoogleAuthService instance = GoogleAuthService._internal();

  final ValueNotifier<String?> driveAccessTokenNotifier =
      ValueNotifier<String?>(null);

  // Configure scopes for Drive file access
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  Future<String?> signInForDrive() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // user cancelled
      }
      final auth = await account.authentication;
      final token = auth.accessToken;
      driveAccessTokenNotifier.value = token;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } finally {
      driveAccessTokenNotifier.value = null;
    }
  }

  String? get currentDriveAccessToken => driveAccessTokenNotifier.value;
}
