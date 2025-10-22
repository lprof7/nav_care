import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    this.controller,
    this.onChanged,
    this.validator,
    this.labelText,
    this.initialCountryCode = 'DZ',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? labelText;
  final String initialCountryCode;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      initialCountryCode: initialCountryCode,
      keyboardType: TextInputType.phone,
      onChanged: (PhoneNumber phone) => onChanged?.call(phone.completeNumber),
      validator: validator != null
          ? (phone) => validator!(phone?.completeNumber ?? '')
          : null,
    );
  }
}
