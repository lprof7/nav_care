import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.languageCode,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<PhoneNumber>? validator;
  final String? labelText;
  final String initialCountryCode;
  final String? languageCode;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: controller,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: labelText,
      ),
      initialCountryCode: initialCountryCode,
      languageCode:
          languageCode ?? Localizations.localeOf(context).languageCode,
      keyboardType: TextInputType.phone,
      onChanged: (PhoneNumber phone) => onChanged?.call(phone.completeNumber),
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
