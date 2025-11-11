import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/utils/app_helpers.dart';

enum InputFieldType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
  search,
}

class CustomInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final InputFieldType type;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsets? contentPadding;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextAlign textAlign;
  final TextStyle? textStyle;

  const CustomInputField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.type = InputFieldType.text,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.maxLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.textAlign = TextAlign.start,
    this.textStyle,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  TextInputType? _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;

    switch (widget.type) {
      case InputFieldType.email:
        return TextInputType.emailAddress;
      case InputFieldType.phone:
        return TextInputType.phone;
      case InputFieldType.number:
        return TextInputType.number;
      case InputFieldType.multiline:
        return TextInputType.multiline;
      case InputFieldType.search:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  int? _getMaxLines() {
    if (widget.maxLines != null) return widget.maxLines;

    switch (widget.type) {
      case InputFieldType.multiline:
        return 3;
      default:
        return 1;
    }
  }

  String? _getHint() {
    if (widget.hint != null) return widget.hint;

    switch (widget.type) {
      case InputFieldType.email:
        return 'Enter email address';
      case InputFieldType.password:
        return 'Enter password';
      case InputFieldType.phone:
        return 'Enter phone number';
      case InputFieldType.number:
        return 'Enter number';
      case InputFieldType.search:
        return 'Search...';
      default:
        return 'Enter text';
    }
  }

  Widget? _getSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;

    if (widget.showPasswordToggle) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textTertiary,
        ),
        onPressed: _togglePasswordVisibility,
      );
    }

    return null;
  }

  String? _validateValue(String? value) {
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return '${widget.label ?? 'This field'} is required';
    }

    switch (widget.type) {
      case InputFieldType.email:
        if (value != null &&
            value.isNotEmpty &&
            !AppHelpers.isValidEmail(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case InputFieldType.phone:
        if (value != null &&
            value.isNotEmpty &&
            !AppHelpers.isValidPhone(value)) {
          return 'Please enter a valid phone number';
        }
        break;
      default:
        break;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.inputLabel,
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: AppTextStyles.inputLabel.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          enabled: widget.isEnabled,
          readOnly: widget.isReadOnly,
          autofocus: widget.autofocus,
          focusNode: _focusNode,
          obscureText: _obscureText,
          maxLines: _getMaxLines(),
          maxLength: widget.maxLength,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          textAlign: widget.textAlign,
          style: widget.textStyle ?? AppTextStyles.inputText,
          inputFormatters: widget.inputFormatters,
          validator: _validateValue,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: _getHint(),
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _getSuffixIcon(),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: widget.isEnabled
                ? (_isFocused ? AppColors.white : AppColors.grey50)
                : AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class CustomDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool isRequired;
  final bool isEnabled;
  final Widget? prefixIcon;
  final EdgeInsets? contentPadding;
  final FocusNode? focusNode;
  final bool autofocus;

  const CustomDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.inputLabel,
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: AppTextStyles.inputLabel.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: widget.value,
          items: widget.items,
          onChanged: widget.isEnabled ? widget.onChanged : null,
          validator: widget.validator ??
              (value) {
                if (widget.isRequired && value == null) {
                  return '${widget.label ?? 'This field'} is required';
                }
                return null;
              },
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Select an option',
            hintStyle: AppTextStyles.inputHint,
            prefixIcon: widget.prefixIcon,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: widget.isEnabled ? AppColors.grey50 : AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }
}
