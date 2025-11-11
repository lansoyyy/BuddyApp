import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:buddyapp/utils/app_constants.dart';
import 'package:buddyapp/services/storage_service.dart';
import 'package:buddyapp/utils/app_helpers.dart';

class AuthService {
  static AuthService? _instance;
  late Dio _dio;
  late StorageService _storageService;

  AuthService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/${AppConstants.apiVersion}',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        if (AppConstants.isDebugModeEnabled) {
          print(object);
        }
      },
    ));
  }

  static Future<AuthService> getInstance() async {
    _instance ??= AuthService._internal();
    _instance!._storageService = await StorageService.getInstance();
    return _instance!;
  }

  // Add authorization header
  void _addAuthHeader() {
    final token = _storageService.getAuthToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Remove authorization header
  void _removeAuthHeader() {
    _dio.options.headers.remove('Authorization');
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _removeAuthHeader();

      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (token != null && userData != null) {
          // Store token and user data
          await _storageService.setAuthToken(token);
          await _storageService.setUserData(userData);

          // Add auth header for future requests
          _addAuthHeader();

          return {
            'success': true,
            'user': userData,
            'token': token,
          };
        }
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      _removeAuthHeader();

      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (token != null && userData != null) {
          // Store token and user data
          await _storageService.setAuthToken(token);
          await _storageService.setUserData(userData);

          // Add auth header for future requests
          _addAuthHeader();

          return {
            'success': true,
            'user': userData,
            'token': token,
          };
        }
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      _addAuthHeader();

      await _dio.post('/auth/logout');

      // Clear local storage
      await _storageService.removeAuthToken();
      await _storageService.removeUserData();
      await _storageService.clearSessionData();

      _removeAuthHeader();

      return {
        'success': true,
        'message': AppConstants.logoutSuccessMessage,
      };
    } on DioException catch (e) {
      // Even if server logout fails, clear local data
      await _storageService.removeAuthToken();
      await _storageService.removeUserData();
      await _storageService.clearSessionData();
      _removeAuthHeader();

      return _handleDioError(e);
    } catch (e) {
      // Even if server logout fails, clear local data
      await _storageService.removeAuthToken();
      await _storageService.removeUserData();
      await _storageService.clearSessionData();
      _removeAuthHeader();

      return {
        'success': true,
        'message': AppConstants.logoutSuccessMessage,
      };
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      _removeAuthHeader();

      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset instructions sent to your email',
        };
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    try {
      _removeAuthHeader();

      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successful',
        };
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _addAuthHeader();

      final response = await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully',
        };
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
  }) async {
    try {
      _addAuthHeader();

      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _dio.put('/auth/profile', data: data);

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>?;
        if (userData != null) {
          await _storageService.setUserData(userData);
        }

        return {
          'success': true,
          'user': userData,
          'message': 'Profile updated successfully',
        };
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final currentToken = _storageService.getAuthToken();
      if (currentToken == null) {
        return {
          'success': false,
          'message': 'No token to refresh',
        };
      }

      _removeAuthHeader();

      final response = await _dio.post(
        '/auth/refresh',
        data: {'token': currentToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String?;

        if (token != null) {
          await _storageService.setAuthToken(token);
          _addAuthHeader();

          return {
            'success': true,
            'token': token,
          };
        }
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.genericErrorMessage,
      };
    }
  }

  // Check Authentication Status
  bool isAuthenticated() {
    return _storageService.hasAuthToken();
  }

  // Get Current User
  Map<String, dynamic>? getCurrentUser() {
    return _storageService.getUserData();
  }

  // Get User Role
  String? getUserRole() {
    final user = getCurrentUser();
    return user?['role'] as String?;
  }

  // Check if user has specific role
  bool hasRole(String role) {
    final userRole = getUserRole();
    return userRole?.toLowerCase() == role.toLowerCase();
  }

  // Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    final userRole = getUserRole();
    if (userRole == null) return false;

    return roles.any((role) => role.toLowerCase() == userRole.toLowerCase());
  }

  // Handle Dio Errors
  Map<String, dynamic> _handleDioError(DioException e) {
    String message = AppConstants.genericErrorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.networkErrorMessage;
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'] as String;
        } else {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = AppConstants.unauthorizedMessage;
              break;
            case 403:
              message = 'Access forbidden. You don\'t have permission.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 422:
              message = 'Validation error. Please check your input.';
              break;
            case 429:
              message = 'Too many requests. Please try again later.';
              break;
            case 500:
            case 502:
            case 503:
            case 504:
              message = AppConstants.serverErrorMessage;
              break;
            default:
              message = 'Request failed with status $statusCode.';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = AppConstants.networkErrorMessage;
        break;
      case DioExceptionType.badCertificate:
        message = 'SSL certificate error. Please check your connection.';
        break;
      case DioExceptionType.unknown:
        message = AppConstants.networkErrorMessage;
        break;
    }

    return {
      'success': false,
      'message': message,
      'error': e.toString(),
    };
  }
}
