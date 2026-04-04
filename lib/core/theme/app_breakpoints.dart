/// Layout breakpoints for phone / tablet+ / desktop-style widths.
abstract final class AppBreakpoints {
  static const double compactMax = 600;
  static const double mediumMax = 840;

  static bool isCompact(double width) => width < compactMax;
  static bool isMediumOrWider(double width) => width >= compactMax;
}
