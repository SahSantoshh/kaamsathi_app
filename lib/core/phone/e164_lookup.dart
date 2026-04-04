import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Resolves [intl_phone_field] metadata for a stored E.164 string (for flags, dial code).
Country? lookupCountryForE164(String? raw) {
  if (raw == null) {
    return null;
  }
  final String t = raw.trim();
  if (t.isEmpty) {
    return null;
  }
  final String withPlus = t.startsWith('+') ? t : '+$t';
  try {
    return PhoneNumber.getCountry(withPlus);
  } on Object {
    return null;
  }
}
