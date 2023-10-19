import 'dart:math';

import 'package:flutter/material.dart';
import 'emoji/emoji_matcher.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart' as material;

final _urlRegex = RegExp(
  r'(?:(?:https?):\/\/|www\.)(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[A-Z0-9+&@#/%=~_|$])',
  caseSensitive: false,
  dotAll: true,
);

enum NewPasswordResult { valid, tooShort, noNumbers, noSymbols, noMixedCase }

class TextUtils {
  static bool isEmoji(String text) {
    var matches = EmojiMatcher.find(text);
    if (matches.length != 1) return false;
    return matches.single.start == 0 && matches.single.end == text.length;
  }

  static String linkifyStringHtml(String text) {
    var matches = _urlRegex.allMatches(text);
    List<String> urlsToReplace = List.empty(growable: true);

    for (int i = 0; i < matches.length; i++) {
      var match = matches.elementAt(i);
      var link = text.substring(match.start, match.end);

      if (!urlsToReplace.contains(link)) {
        urlsToReplace.add(link);
      }
    }

    for (var link in urlsToReplace) {
      text = text.replaceAll(link, '<a href="$link">$link</a>');
    }

    return text;
  }

  static NewPasswordResult isValidPassword(
    String password, {
    bool forceDigits = false,
    int? forceLength,
    bool forceSpecialCharacter = false,
  }) {
    if (forceLength != null) {
      if (password.length < forceLength) return NewPasswordResult.tooShort;
    }

    if (forceDigits) {
      if (!password.characters.any((char) => int.tryParse(char) != null)) {
        return NewPasswordResult.noNumbers;
      }
    }

    if (forceSpecialCharacter) {
      if (!password.characters.any(
          (char) => ("!@#\$%^&*()_+`{}|:\"<>?/.,';][=-\\").contains(char))) {
        return NewPasswordResult.noSymbols;
      }
    }

    return NewPasswordResult.valid;
  }

  static String timestampToLocalizedTime(DateTime time) {
    var difference = DateTime.now().difference(time);

    if (difference.inDays == 0) {
      return intl.DateFormat(intl.DateFormat.HOUR_MINUTE)
          .format(time.toLocal());
    }

    if (difference.inDays < 365) {
      return intl.DateFormat(intl.DateFormat.MONTH_WEEKDAY_DAY)
          .format(time.toLocal());
    }

    return intl.DateFormat(intl.DateFormat.YEAR_MONTH_WEEKDAY_DAY)
        .format(time.toLocal());
  }

  static String readableFileSize(num number, {bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (number <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(number) / log(base)).round();
    // ignore: prefer_interpolation_to_compose_strings
    return intl.NumberFormat("#,##0.#")
            .format(number / pow(base, digitGroups)) +
        " " +
        units[digitGroups];
  }
}
