import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

/// Phone input with country selector and searchable country list (name / dial code).
class KaamPhoneField extends StatelessWidget {
  const KaamPhoneField({
    super.key,
    required this.decoration,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autovalidateMode,
    this.onChanged,
    /// Called when the national number or selected country changes (for building E.164 on submit).
    this.onPhoneUpdate,
    this.initialCountryCode,
    this.onSubmitted,
    this.textInputAction,
  });

  final InputDecoration decoration;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<PhoneNumber>? onChanged;
  final ValueChanged<PhoneNumber>? onPhoneUpdate;
  final String? initialCountryCode;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;

  void _emitPhoneUpdate(Country country, String national) {
    onPhoneUpdate?.call(
      PhoneNumber(
        countryISOCode: country.code,
        countryCode: '+${country.fullCountryCode}',
        number: national,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final Locale locale = Localizations.localeOf(context);
    final String? countryCode =
        initialCountryCode ??
            (locale.countryCode != null && locale.countryCode!.isNotEmpty
                ? locale.countryCode
                : 'NP');

    return IntlPhoneField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      autovalidateMode: autovalidateMode,
      decoration: decoration,
      initialCountryCode: countryCode,
      languageCode: locale.languageCode,
      invalidNumberMessage: l10n.authErrorPhoneInvalid,
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor:
            theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        searchFieldInputDecoration: InputDecoration(
          labelText: l10n.phoneCountrySearchHint,
          suffixIcon: const Icon(Icons.search_rounded),
        ),
      ),
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      onCountryChanged: controller != null && onPhoneUpdate != null
          ? (Country country) {
              _emitPhoneUpdate(country, controller!.text);
            }
          : null,
      onChanged: (PhoneNumber phone) {
        onChanged?.call(phone);
        onPhoneUpdate?.call(phone);
      },
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
    );
  }
}
