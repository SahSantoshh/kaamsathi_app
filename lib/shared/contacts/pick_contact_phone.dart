import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../core/phone/device_contact_phone.dart';

const PermissionType _contactsReadPermission = PermissionType.read;

/// Same as [ContactProperties.allProperties] plus a thumbnail for list rows (native-style avatars).
final Set<ContactProperty> _pickerContactProperties = <ContactProperty>{
  ...ContactProperties.allProperties,
  ContactProperty.photoThumbnail,
};

/// Phone number, optional email, optional name parts, and optional profile photo from a contact.
class ContactContracteePick {
  const ContactContracteePick({
    required this.phone,
    this.email,
    this.firstName,
    this.middleName,
    this.lastName,
    this.avatarBytes,
  });

  final PhoneNumber phone;
  final String? email;

  final String? firstName;
  final String? middleName;
  final String? lastName;

  /// Thumbnail image bytes for `project_site[contractee][avatar]` / `PATCH /me` `user[avatar]`.
  final Uint8List? avatarBytes;
}

/// Requests read access to contacts, loads address-book entries with full details, then opens an
/// in-app picker (search, phones, emails, org, address, etc.) and returns a parsed phone plus an
/// email when the contact has at least one address.
Future<ContactContracteePick?> pickContactPhoneNumber(
  BuildContext context, {
  String defaultCountryIso = 'NP',
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sitesContactsNotAvailableOnPlatform)),
      );
    }
    return null;
  }

  try {
    PermissionStatus status =
        await FlutterContacts.permissions.check(_contactsReadPermission);
    if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
      status =
          await FlutterContacts.permissions.request(_contactsReadPermission);
    }
    if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
      if (!context.mounted) {
        return null;
      }
      await _showContactsPermissionDeniedUi(context, l10n, status);
      return null;
    }

    if (!context.mounted) {
      return null;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(width: 24),
                Expanded(child: Text(l10n.sitesContactsLoading)),
              ],
            ),
          ),
        );
      },
    );

    List<Contact> contacts;
    try {
      contacts = await FlutterContacts.getAll(
        properties: _pickerContactProperties,
      );
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!context.mounted) {
      return null;
    }

    return Navigator.of(context).push<ContactContracteePick?>(
      MaterialPageRoute<ContactContracteePick?>(
        fullscreenDialog: true,
        builder: (BuildContext ctx) => _ContactPhonePickerPage(
          contacts: contacts,
          defaultCountryIso: defaultCountryIso,
        ),
      ),
    );
  } on PlatformException catch (e, st) {
    debugPrint('pickContactPhone PlatformException: $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.sitesContactsPickerError(e.message ?? e.code),
          ),
        ),
      );
    }
    return null;
  } catch (e, st) {
    debugPrint('pickContactPhone: $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sitesContactsPickerError(e.toString())),
        ),
      );
    }
    return null;
  }
}

class _ContactPhonePickerPage extends StatefulWidget {
  const _ContactPhonePickerPage({
    required this.contacts,
    required this.defaultCountryIso,
  });

  final List<Contact> contacts;
  final String defaultCountryIso;

  @override
  State<_ContactPhonePickerPage> createState() => _ContactPhonePickerPageState();
}

class _ContactPhonePickerPageState extends State<_ContactPhonePickerPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Contact> get _filtered {
    final String q = _search.text.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.contacts;
    }
    return widget.contacts
        .where((Contact c) => _contactMatchesQuery(c, q))
        .toList();
  }

  Future<void> _onContactTapped(Contact c) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Phone> phones = c.phones;
    if (phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sitesContactNoPhones)),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final Phone? selectedPhone;
    if (phones.length == 1) {
      selectedPhone = phones.first;
    } else {
      selectedPhone = await _showPhoneChoicesBottomSheet(
        context,
        contactName: c.displayName ?? '',
        phones: phones,
        l10n: l10n,
      );
    }
    if (!mounted || selectedPhone == null) {
      return;
    }

    final PhoneNumber? pn = _parsePhone(
      selectedPhone,
      defaultCountryIso: widget.defaultCountryIso,
    );
    if (pn == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sitesContactInvalidPhone)),
        );
      }
      return;
    }

    final String? email =
        await _resolvePickedEmail(context, contact: c, l10n: l10n);
    if (!mounted) {
      return;
    }
    final ({String? first, String? middle, String? last}) names =
        _contracteeNamePartsFromContact(c);
    Navigator.pop(
      context,
      ContactContracteePick(
        phone: pn,
        email: email,
        firstName: names.first,
        middleName: names.middle,
        lastName: names.last,
        avatarBytes: _copyContactAvatarBytes(c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final List<Contact> list = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sitesContactsPickerTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: l10n.sitesContactsSearchHint,
              controller: _search,
              leading: const Icon(Icons.search_rounded),
              trailing: <Widget>[
                if (_search.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _search.clear();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.contacts.isEmpty
                            ? l10n.sitesContactsEmptyList
                            : l10n.sitesContactsNoMatches,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext ctx, int i) {
                      final Contact c = list[i];
                      final String name =
                          (c.displayName ?? '').trim().isEmpty
                              ? '—'
                              : c.displayName!.trim();
                      return Material(
                        color: theme.colorScheme.surface,
                        child: InkWell(
                          onTap: () => _onContactTapped(c),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _ContactPickerAvatar(
                                  bytes: c.photo?.thumbnail,
                                  name: name,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      _ContactPickerMetaLines(
                                        contact: c,
                                        l10n: l10n,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// When a contact has multiple phone numbers, shows a sheet to pick one.
Future<Phone?> _showPhoneChoicesBottomSheet(
  BuildContext context, {
  required String contactName,
  required List<Phone> phones,
  required AppLocalizations l10n,
}) {
  return showModalBottomSheet<Phone>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      final double maxH = MediaQuery.sizeOf(ctx).height * 0.5;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                l10n.sitesPickPhoneTitle(contactName),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: phones.length,
                itemBuilder: (BuildContext _, int i) {
                  final Phone p = phones[i];
                  return ListTile(
                    leading: const Icon(Icons.phone_rounded),
                    title: Text(_displayNumber(p)),
                    subtitle: Text(_phoneLabel(p, l10n)),
                    onTap: () => Navigator.pop(ctx, p),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Returns a trimmed email, or null if the contact has none.
Future<String?> _resolvePickedEmail(
  BuildContext context, {
  required Contact contact,
  required AppLocalizations l10n,
}) async {
  final List<Email> emails = _emailsSortedForPick(contact.emails);
  if (emails.isEmpty) {
    return null;
  }
  if (emails.length == 1) {
    return emails.single.address.trim();
  }
  if (!context.mounted) {
    return null;
  }
  final Email? choice = await _showEmailChoicesBottomSheet(
    context,
    contactName: contact.displayName ?? '',
    emails: emails,
    l10n: l10n,
  );
  return choice?.address.trim();
}

/// Puts primary email first (Android), then keeps platform order.
List<Email> _emailsSortedForPick(List<Email> emails) {
  final List<Email> copy = List<Email>.from(emails);
  copy.sort((Email a, Email b) {
    final bool ap = a.isPrimary == true;
    final bool bp = b.isPrimary == true;
    if (ap && !bp) {
      return -1;
    }
    if (!ap && bp) {
      return 1;
    }
    return 0;
  });
  return copy;
}

Future<Email?> _showEmailChoicesBottomSheet(
  BuildContext context, {
  required String contactName,
  required List<Email> emails,
  required AppLocalizations l10n,
}) {
  return showModalBottomSheet<Email>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      final double maxH = MediaQuery.sizeOf(ctx).height * 0.5;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                l10n.sitesPickEmailTitle(contactName),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: emails.length,
                itemBuilder: (BuildContext _, int i) {
                  final Email e = emails[i];
                  return ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(e.address),
                    subtitle: Text(_emailLabel(e, l10n)),
                    onTap: () => Navigator.pop(ctx, e),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Uint8List? _copyContactAvatarBytes(Contact c) {
  final Uint8List? t = c.photo?.thumbnail;
  if (t == null || t.isEmpty) {
    return null;
  }
  return Uint8List.fromList(t);
}

/// Maps [Contact.name] to first/middle/last; if missing, splits [Contact.displayName] on whitespace.
({String? first, String? middle, String? last}) _contracteeNamePartsFromContact(
  Contact c,
) {
  String? trimOrNull(String? s) {
    final String? t = s?.trim();
    if (t == null || t.isEmpty) {
      return null;
    }
    return t;
  }

  final Name? n = c.name;
  String? first = trimOrNull(n?.first);
  String? middle = trimOrNull(n?.middle);
  String? last = trimOrNull(n?.last);
  if (first != null || middle != null || last != null) {
    return (first: first, middle: middle, last: last);
  }

  final String display = (c.displayName ?? '').trim();
  if (display.isEmpty) {
    return (first: null, middle: null, last: null);
  }
  final List<String> parts =
      display.split(RegExp(r'\s+')).where((String s) => s.isNotEmpty).toList();
  if (parts.isEmpty) {
    return (first: null, middle: null, last: null);
  }
  if (parts.length == 1) {
    return (first: parts.single, middle: null, last: null);
  }
  if (parts.length == 2) {
    return (first: parts[0], middle: null, last: parts[1]);
  }
  final String f = parts.first;
  final String l = parts.last;
  final String m = parts.sublist(1, parts.length - 1).join(' ');
  return (first: f, middle: m, last: l);
}

String _contactDisplayInitial(String name) {
  final String trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == '—') {
    return '?';
  }
  final Iterator<int> it = trimmed.runes.iterator;
  if (!it.moveNext()) {
    return '?';
  }
  return String.fromCharCode(it.current).toUpperCase();
}

class _ContactPickerAvatar extends StatelessWidget {
  const _ContactPickerAvatar({
    required this.bytes,
    required this.name,
  });

  final Uint8List? bytes;
  final String name;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const double radius = 28;
    if (bytes != null && bytes!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(bytes!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      child: Text(
        _contactDisplayInitial(name),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactPickerMetaLines extends StatelessWidget {
  const _ContactPickerMetaLines({
    required this.contact,
    required this.l10n,
  });

  final Contact contact;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<Widget> lines = <Widget>[];

    if (contact.phones.isNotEmpty) {
      lines.add(
        Text(
          contact.phones.map(_displayNumber).join(' · '),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface,
            height: 1.3,
          ),
        ),
      );
    }
    if (contact.emails.isNotEmpty) {
      final String emails = contact.emails
          .map((Email e) => e.address.trim())
          .where((String s) => s.isNotEmpty)
          .join(' · ');
      if (emails.isNotEmpty) {
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              emails,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        );
      }
    }
    for (final Organization o in contact.organizations) {
      final List<String> bits = <String>[];
      if (o.name != null && o.name!.trim().isNotEmpty) {
        bits.add(o.name!.trim());
      }
      if (o.jobTitle != null && o.jobTitle!.trim().isNotEmpty) {
        bits.add(o.jobTitle!.trim());
      }
      if (bits.isNotEmpty) {
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              bits.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.25,
              ),
            ),
          ),
        );
        break;
      }
    }
    if (contact.addresses.isNotEmpty) {
      final String? addr = _pickerAddressSummaryLine(contact.addresses.first);
      if (addr != null && addr.isNotEmpty) {
        lines.add(
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              addr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.25,
              ),
            ),
          ),
        );
      }
    }

    if (lines.isEmpty) {
      return Text(
        l10n.sitesContactsNoPhoneOrEmailLine,
        style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }
}

String? _pickerAddressSummaryLine(Address a) {
  final String? f = a.formatted?.trim();
  if (f != null && f.isNotEmpty) {
    return f;
  }
  final List<String> bits = <String>[
    if (a.street != null && a.street!.trim().isNotEmpty) a.street!.trim(),
    if (a.city != null && a.city!.trim().isNotEmpty) a.city!.trim(),
    if (a.state != null && a.state!.trim().isNotEmpty) a.state!.trim(),
    if (a.postalCode != null && a.postalCode!.trim().isNotEmpty) a.postalCode!.trim(),
    if (a.country != null && a.country!.trim().isNotEmpty) a.country!.trim(),
  ];
  if (bits.isEmpty) {
    return null;
  }
  return bits.join(', ');
}

bool _contactMatchesQuery(Contact c, String q) {
  return _contactSearchHaystack(c).contains(q);
}

/// Lowercase blob of text used for quick client-side search.
String _contactSearchHaystack(Contact c) {
  final StringBuffer b = StringBuffer();
  void w(String? s) {
    if (s == null) {
      return;
    }
    final String t = s.trim();
    if (t.isEmpty) {
      return;
    }
    b.write(t.toLowerCase());
    b.write(' ');
  }

  w(c.displayName);
  w(c.name?.first);
  w(c.name?.last);
  for (final Phone p in c.phones) {
    w(_displayNumber(p));
    w(p.number);
  }
  for (final Email e in c.emails) {
    w(e.address);
  }
  for (final Organization o in c.organizations) {
    w(o.name);
    w(o.jobTitle);
    w(o.departmentName);
  }
  for (final Address a in c.addresses) {
    w(a.formatted);
    w(a.street);
    w(a.city);
    w(a.state);
    w(a.postalCode);
    w(a.country);
  }
  for (final Website web in c.websites) {
    w(web.url);
  }
  for (final SocialMedia sm in c.socialMedias) {
    w(sm.username);
  }
  for (final Event ev in c.events) {
    w('${ev.month}/${ev.day}');
    if (ev.year != null) {
      w(ev.year.toString());
    }
  }
  for (final Note n in c.notes) {
    w(n.note);
  }
  for (final Relation r in c.relations) {
    w(r.name);
  }
  return b.toString();
}

Future<void> _showContactsPermissionDeniedUi(
  BuildContext context,
  AppLocalizations l10n,
  PermissionStatus status,
) async {
  if (!context.mounted) {
    return;
  }
  if (status == PermissionStatus.permanentlyDenied ||
      status == PermissionStatus.restricted) {
    final bool? open = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.sitesContactsPermissionTitle),
        content: Text(l10n.sitesContactsPermissionSettingsBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.sitesContactsOpenSettings),
          ),
        ],
      ),
    );
    if (open == true) {
      await FlutterContacts.permissions.openSettings();
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.sitesContactsPermissionDenied)),
    );
  }
}

String _displayNumber(Phone p) {
  final String? n = p.normalizedNumber?.trim();
  if (n != null && n.isNotEmpty) {
    return n;
  }
  return p.number.trim();
}

PhoneNumber? _parsePhone(
  Phone phone, {
  required String defaultCountryIso,
}) {
  final String raw = _displayNumber(phone);
  return phoneNumberFromDeviceString(raw, defaultCountryIso: defaultCountryIso);
}

String _phoneLabel(Phone p, AppLocalizations l10n) {
  if (p.label.label == PhoneLabel.custom) {
    return p.label.customLabel ?? l10n.sitesPhoneLabelOther;
  }
  return p.label.label.name;
}

String _emailLabel(Email e, AppLocalizations l10n) {
  if (e.label.label == EmailLabel.custom) {
    return e.label.customLabel ?? l10n.sitesPhoneLabelOther;
  }
  return e.label.label.name;
}
