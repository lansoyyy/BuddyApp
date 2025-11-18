import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:buddyapp/utils/app_helpers.dart';
import 'package:buddyapp/services/storage_service.dart';

class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static StorageService? _storageService;

  FirebaseAuthService._internal();

  static Future<FirebaseAuthService> getInstance() async {
    _instance ??= FirebaseAuthService._internal();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _storageService = await StorageService.getInstance();
    return _instance!;
  }

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth!.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    bool agreeToTerms = false,
    bool agreeToPrivacy = false,
  }) async {
    try {
      // Validate input
      if (!agreeToTerms || !agreeToPrivacy) {
        return {
          'success': false,
          'message': 'You must agree to Terms & Conditions and Privacy Policy',
        };
      }

      if (!AppHelpers.isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address',
        };
      }

      if (!AppHelpers.isValidPassword(password)) {
        return {
          'success': false,
          'message':
              'Password must be at least 8 characters with uppercase, lowercase, number, and special character',
        };
      }

      // Create user with email and password
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        return {
          'success': false,
          'message': 'Failed to create user account',
        };
      }

      // Update user profile
      await user.updateDisplayName('$firstName $lastName');

      // Store additional user data in Firestore
      final userData = {
        'uid': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role,
        'avatar': null,
        'isActive': true,
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'agreedToTerms': agreeToTerms,
        'agreedToPrivacy': agreeToPrivacy,
        'preferences': {
          'notifications': true,
          'darkMode': false,
          'autoBackup': true,
        },
      };

      await _firestore!.collection('users').doc(user.uid).set(userData);

      // Send email verification
      await user.sendEmailVerification();

      // Create a copy of userData for local storage with proper timestamps
      final localUserData = Map<String, dynamic>.from(userData);
      localUserData['createdAt'] = DateTime.now().toIso8601String();
      localUserData['lastLoginAt'] = DateTime.now().toIso8601String();

      // Store user data locally
      await _storageService!.setUserData(localUserData);

      return {
        'success': true,
        'user': user,
        'userData': userData,
        'message':
            'Account created successfully. Please check your email for verification.',
      };
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      developer.log('Unexpected error during sign up: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (!AppHelpers.isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address',
        };
      }

      if (password.isEmpty) {
        return {
          'success': false,
          'message': 'Password is required',
        };
      }

      // Sign in user
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        return {
          'success': false,
          'message': 'Failed to sign in. Please check your credentials.',
        };
      }

      // Get user data from Firestore
      final userDoc = await _firestore!.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        return {
          'success': false,
          'message': 'User data not found. Please contact support.',
        };
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Update last login
      await _firestore!.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Create a copy of userData for local storage with proper timestamps
      final localUserData = <String, dynamic>{};

      userData.forEach((key, value) {
        if (value is Timestamp) {
          localUserData[key] = value.toDate().toIso8601String();
        } else {
          localUserData[key] = value;
        }
      });

      // Update last login time for local storage
      localUserData['lastLoginAt'] = DateTime.now().toIso8601String();

      // Store user data locally
      await _storageService!.setUserData(localUserData);

      return {
        'success': true,
        'user': user,
        'userData': userData,
        'message': 'Sign in successful',
      };
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      developer.log('Unexpected error during sign in: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // This requires additional setup for Google Sign-In
      return {
        'success': false,
        'message': 'Google Sign-In not implemented yet',
      };
    } catch (e) {
      developer.log('Error during Google sign in: $e');
      return {
        'success': false,
        'message': 'Failed to sign in with Google',
      };
    }
  }

  // Sign out
  Future<Map<String, dynamic>> signOut() async {
    try {
      await _auth!.signOut();

      // Clear local storage
      await _storageService!.removeUserData();
      await _storageService!.removeAuthToken();

      return {
        'success': true,
        'message': 'Signed out successfully',
      };
    } catch (e) {
      developer.log('Error during sign out: $e');
      return {
        'success': false,
        'message': 'Failed to sign out',
      };
    }
  }

  // Send password reset email
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      if (!AppHelpers.isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address',
        };
      }

      await _auth!.sendPasswordResetEmail(email: email);

      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      developer.log('Unexpected error during password reset: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in',
        };
      }

      if (!AppHelpers.isValidPassword(newPassword)) {
        return {
          'success': false,
          'message':
              'New password must be at least 8 characters with uppercase, lowercase, number, and special character',
        };
      }

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      developer.log('Unexpected error during password change: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  }) async {
    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in',
        };
      }

      // Update display name
      if (firstName != null || lastName != null) {
        final displayName = '$firstName $lastName'.trim();
        await user.updateDisplayName(displayName);
      }

      // Update Firestore data
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (avatar != null) updateData['avatar'] = avatar;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore!.collection('users').doc(user.uid).update(updateData);

      // Get updated user data
      final userDoc = await _firestore!.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Create a copy of userData for local storage with proper timestamps
      final localUserData = <String, dynamic>{};

      userData.forEach((key, value) {
        if (value is Timestamp) {
          localUserData[key] = value.toDate().toIso8601String();
        } else {
          localUserData[key] = value;
        }
      });

      // Update local storage
      await _storageService!.setUserData(localUserData);

      return {
        'success': true,
        'userData': userData,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      developer.log('Error during profile update: $e');
      return {
        'success': false,
        'message': 'Failed to update profile',
      };
    }
  }

  // Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in',
        };
      }

      // Delete user data from Firestore
      await _firestore!.collection('users').doc(user.uid).delete();

      // Delete user profile picture from Storage if exists
      try {
        final ref = _storage!.ref().child('avatars/${user.uid}');
        await ref.delete();
      } catch (e) {
        developer.log('Error deleting avatar: $e');
      }

      // Delete user from Firebase Auth
      await user.delete();

      // Clear local storage
      await _storageService!.removeUserData();
      await _storageService!.removeAuthToken();

      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
    } on FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      developer.log('Unexpected error during account deletion: $e');
      return {
        'success': false,
        'message': 'Failed to delete account',
      };
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _auth?.currentUser != null;
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore!.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Create a copy of userData for local storage with proper timestamps
        final localUserData = <String, dynamic>{};

        userData.forEach((key, value) {
          if (value is Timestamp) {
            localUserData[key] = value.toDate().toIso8601String();
          } else {
            localUserData[key] = value;
          }
        });

        return localUserData;
      }

      return null;
    } catch (e) {
      developer.log('Error getting user data: $e');
      return null;
    }
  }

  // Upload profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user is currently signed in',
        };
      }

      final file = File(filePath);
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage!.ref().child('avatars/$fileName');

      // Upload file
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user profile with avatar URL
      final result = await updateProfile(avatar: downloadUrl);

      if (result['success']) {
        return {
          'success': true,
          'avatarUrl': downloadUrl,
          'message': 'Profile picture uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update profile with new picture',
        };
      }
    } catch (e) {
      developer.log('Error uploading profile picture: $e');
      return {
        'success': false,
        'message': 'Failed to upload profile picture',
      };
    }
  }

  // Get Firebase Auth error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Email address is invalid';
      case 'email-already-in-use':
        return 'Email address is already in use';
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'invalid-credential':
        return 'Invalid credentials';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'expired-action-code':
        return 'Action code has expired';
      default:
        return 'An authentication error occurred';
    }
  }

  // Refresh user token
  Future<String?> getIdToken() async {
    try {
      final user = _auth!.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      developer.log('Error getting ID token: $e');
      return null;
    }
  }
}
