import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Maps a string from the device address book into [PhoneNumber] for [IntlPhoneField] / [KaamPhoneField].
///
/// Prefer E.164 / international formats; falls back to [defaultCountryIso] for bare national numbers.
PhoneNumber? phoneNumberFromDeviceString(
  String raw, {
  String defaultCountryIso = 'NP',
}) {
  String t = raw.trim();
  if (t.isEmpty) {
    return null;
  }
  t = t.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  final String complete = t.startsWith('+') ? t : '+$t';
  final PhoneNumber parsed =
      PhoneNumber.fromCompleteNumber(completeNumber: complete);
  if (parsed.countryISOCode.isNotEmpty) {
    return parsed;
  }

  final Country country = _countryByIso(defaultCountryIso);
  final String dial = country.dialCode + country.regionCode;
  final String digitsOnly = t.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.isEmpty) {
    return null;
  }
  String national = digitsOnly;
  if (national.startsWith(dial)) {
    national = national.substring(dial.length);
  }
  if (national.isEmpty) {
    return null;
  }
  return PhoneNumber(
    countryISOCode: country.code,
    countryCode: country.dialCode + country.regionCode,
    number: national,
  );
}

Country _countryByIso(String iso) {
  return countries.firstWhere(
    (Country c) => c.code == iso,
    orElse: () => countries.firstWhere((Country c) => c.code == 'NP'),
  );
}
