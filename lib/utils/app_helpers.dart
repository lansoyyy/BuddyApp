import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_constants.dart';

class AppHelpers {
  // Date and Time Helpers
  static String formatDate(DateTime? date, {String? format}) {
    if (date == null) return '';
    final formatter = DateFormat(format ?? AppConstants.displayDateFormat);
    return formatter.format(date);
  }

  static String formatDateTime(DateTime? dateTime, {String? format}) {
    if (dateTime == null) return '';
    final formatter = DateFormat(format ?? AppConstants.displayDateTimeFormat);
    return formatter.format(dateTime);
  }

  static String formatTime(DateTime? time, {String? format}) {
    if (time == null) return '';
    final formatter = DateFormat(format ?? AppConstants.shortTimeFormat);
    return formatter.format(time);
  }

  static DateTime? parseDate(String? dateString, {String? format}) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final formatter = DateFormat(format ?? AppConstants.apiDateFormat);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDateTime(String? dateTimeString, {String? format}) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      final formatter = DateFormat(format ?? AppConstants.apiDateTimeFormat);
      return formatter.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  // String Helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncate(String text, int length, {String suffix = '...'}) {
    if (text.length <= length) return text;
    return text.substring(0, length) + suffix;
  }

  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  static bool isValidEmail(String? email) {
    if (isNullOrEmpty(email)) return false;
    return RegExp(AppConstants.emailPattern).hasMatch(email!);
  }

  static bool isValidPhone(String? phone) {
    if (isNullOrEmpty(phone)) return false;
    return RegExp(AppConstants.phonePattern).hasMatch(phone!);
  }

  static bool isValidPassword(String? password) {
    if (isNullOrEmpty(password)) return false;
    return RegExp(AppConstants.passwordPattern).hasMatch(password!);
  }

  static bool isValidWorkOrder(String? workOrder) {
    if (isNullOrEmpty(workOrder)) return false;
    return RegExp(AppConstants.workOrderPattern).hasMatch(workOrder!);
  }

  // File Size Helpers
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static int parseFileSize(String size) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*(B|KB|MB|GB)');
    final match = regex.firstMatch(size.toUpperCase());
    if (match == null) return 0;

    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!;

    switch (unit) {
      case 'B':
        return value.toInt();
      case 'KB':
        return (value * 1024).toInt();
      case 'MB':
        return (value * 1024 * 1024).toInt();
      case 'GB':
        return (value * 1024 * 1024 * 1024).toInt();
      default:
        return 0;
    }
  }

  // Number Helpers
  static String formatNumber(num number, {int decimalDigits = 2}) {
    return NumberFormat('#,##0.${'0' * decimalDigits}').format(number);
  }

  static String formatCurrency(num amount, {String currency = 'USD'}) {
    return NumberFormat.currency(symbol: currency, decimalDigits: 2)
        .format(amount);
  }

  static double parseDouble(String? value, {double defaultValue = 0.0}) {
    if (isNullOrEmpty(value)) return defaultValue;
    try {
      return double.parse(value!);
    } catch (e) {
      return defaultValue;
    }
  }

  static int parseInt(String? value, {int defaultValue = 0}) {
    if (isNullOrEmpty(value)) return defaultValue;
    try {
      return int.parse(value!);
    } catch (e) {
      return defaultValue;
    }
  }

  // UI Helpers
  static void showToast(String message,
      {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.grey800,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  static void showSuccessToast(String message,
      {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.success,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  static void showErrorToast(String message,
      {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      fontSize: 14.0,
    );
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  // Validation Helpers
  static String? validateEmail(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Password is required';
    }
    if (value!.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (!isValidPassword(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Name is required';
    }
    if (value!.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (isNullOrEmpty(value)) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateWorkOrder(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Work order is required';
    }
    if (!isValidWorkOrder(value)) {
      return 'Please enter a valid work order (e.g., ABC-1234)';
    }
    return null;
  }

  // URL Helpers
  static bool isValidUrl(String? url) {
    if (isNullOrEmpty(url)) return false;
    try {
      final uri = Uri.parse(url!);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String? extractFileExtension(String? fileName) {
    if (isNullOrEmpty(fileName)) return null;
    final lastDot = fileName!.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(lastDot + 1).toLowerCase() : null;
  }

  static String getFileName(String? filePath) {
    if (isNullOrEmpty(filePath)) return '';
    final lastSlash = filePath!.lastIndexOf('/');
    final fileName =
        lastSlash != -1 ? filePath.substring(lastSlash + 1) : filePath;
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(0, lastDot) : fileName;
  }

  // Color Helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'approved':
        return AppColors.success;
      case 'pending':
      case 'in progress':
      case 'processing':
        return AppColors.warning;
      case 'failed':
      case 'error':
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      case 'info':
      case 'draft':
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }

  static String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'approved':
        return '✓';
      case 'pending':
      case 'in progress':
      case 'processing':
        return '⏳';
      case 'failed':
      case 'error':
      case 'rejected':
      case 'cancelled':
        return '✗';
      case 'info':
      case 'draft':
        return 'ℹ';
      default:
        return '•';
    }
  }

  // List Helpers
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<T> sortByProperty<T>(List<T> list, String property,
      {bool ascending = true}) {
    list.sort((a, b) {
      final aValue = (a as dynamic)[property];
      final bValue = (b as dynamic)[property];

      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return ascending ? -1 : 1;
      if (bValue == null) return ascending ? 1 : -1;

      return ascending
          ? aValue.toString().compareTo(bValue.toString())
          : bValue.toString().compareTo(aValue.toString());
    });
    return list;
  }

  static T? findFirst<T>(List<T> list, bool Function(T) test) {
    try {
      return list.firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  // Debounce Helper
  static Function debounce(Function func, int delay) {
    Timer? timer;
    return () {
      if (timer != null) timer!.cancel();
      timer = Timer(Duration(milliseconds: delay), () => func());
    };
  }
}

// Extension for String
extension StringExtension on String {
  String capitalize() => AppHelpers.capitalize(this);
  String capitalizeWords() => AppHelpers.capitalizeWords(this);
  String truncate(int length, {String suffix = '...'}) =>
      AppHelpers.truncate(this, length, suffix: suffix);
  bool get isNullOrEmpty => AppHelpers.isNullOrEmpty(this);
  bool get isValidEmail => AppHelpers.isValidEmail(this);
  bool get isValidPhone => AppHelpers.isValidPhone(this);
  bool get isValidPassword => AppHelpers.isValidPassword(this);
  bool get isValidWorkOrder => AppHelpers.isValidWorkOrder(this);
  bool get isValidUrl => AppHelpers.isValidUrl(this);
  String? get fileExtension => AppHelpers.extractFileExtension(this);
  String get fileName => AppHelpers.getFileName(this);
}

// Extension for DateTime
extension DateTimeExtension on DateTime {
  String formatDate({String? format}) =>
      AppHelpers.formatDate(this, format: format);
  String formatDateTime({String? format}) =>
      AppHelpers.formatDateTime(this, format: format);
  String formatTime({String? format}) =>
      AppHelpers.formatTime(this, format: format);
}

// Extension for num
extension NumExtension on num {
  String formatNumber({int decimalDigits = 2}) =>
      AppHelpers.formatNumber(this, decimalDigits: decimalDigits);
  String formatCurrency({String currency = 'USD'}) =>
      AppHelpers.formatCurrency(this, currency: currency);
}

// Extension for int
extension IntExtension on int {
  String formatFileSize() => AppHelpers.formatFileSize(this);
}
