#!/usr/bin/env python3
"""
Script de migration v2 : remplace Icon(Icons.xxx) par HugeIcon(icon: HugeIcons.xxx, ...)
Utilise un parseur de parenthèses balancées pour gérer les expressions complexes.
"""

import os
import re

# ────── Mapping Icons.xxx → HugeIcons.strokeRoundedXxx ──────────────────────
# Tous les noms ont été vérifiés dans la bibliothèque hugeicons-1.1.6
ICON_MAP = {
    "Icons.add":                                         "HugeIcons.strokeRoundedAdd01",
    "Icons.add_a_photo_outlined":                        "HugeIcons.strokeRoundedCameraAdd01",
    "Icons.add_shopping_cart":                           "HugeIcons.strokeRoundedShoppingCartAdd01",
    "Icons.analytics_outlined":                          "HugeIcons.strokeRoundedAnalytics01",
    "Icons.arrow_back":                                  "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.arrow_back_ios_new":                          "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.arrow_back_rounded":                          "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.arrow_forward":                               "HugeIcons.strokeRoundedArrowRight01",
    "Icons.arrow_forward_ios":                           "HugeIcons.strokeRoundedArrowRight01",
    "Icons.auto_awesome":                                "HugeIcons.strokeRoundedSparkles",
    "Icons.broken_image":                                "HugeIcons.strokeRoundedImageNotFound01",
    "Icons.calendar_today_outlined":                     "HugeIcons.strokeRoundedCalendar01",
    "Icons.call_outlined":                               "HugeIcons.strokeRoundedCall",
    "Icons.camera_alt":                                  "HugeIcons.strokeRoundedCamera01",
    "Icons.chat_bubble_outline":                         "HugeIcons.strokeRoundedBubbleChatQuestion",
    "Icons.check":                                       "HugeIcons.strokeRoundedTick01",
    "Icons.check_circle":                                "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.check_circle_outline":                        "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.check_circle_outline_rounded":                "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.check_circle_rounded":                        "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.chevron_left":                                "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.chevron_right":                               "HugeIcons.strokeRoundedArrowRight01",
    "Icons.circle":                                      "HugeIcons.strokeRoundedCircle",
    "Icons.clear":                                       "HugeIcons.strokeRoundedCancel01",
    "Icons.close":                                       "HugeIcons.strokeRoundedCancel01",
    "Icons.close_rounded":                               "HugeIcons.strokeRoundedCancel01",
    "Icons.cloud_off":                                   "HugeIcons.strokeRoundedCloudOff",
    "Icons.comment":                                     "HugeIcons.strokeRoundedComment01",
    "Icons.contactless":                                 "HugeIcons.strokeRoundedNfc",
    "Icons.credit_card":                                 "HugeIcons.strokeRoundedCreditCard",
    "Icons.cut_outlined":                                "HugeIcons.strokeRoundedScissors01",
    "Icons.delete_outline":                              "HugeIcons.strokeRoundedDelete01",
    "Icons.download_outlined":                           "HugeIcons.strokeRoundedDownload01",
    "Icons.edit":                                        "HugeIcons.strokeRoundedEdit01",
    "Icons.edit_outlined":                               "HugeIcons.strokeRoundedEdit01",
    "Icons.email_outlined":                              "HugeIcons.strokeRoundedMail01",
    "Icons.error_outline":                               "HugeIcons.strokeRoundedAlertCircle",
    "Icons.error_outline_rounded":                       "HugeIcons.strokeRoundedAlertCircle",
    "Icons.facebook":                                    "HugeIcons.strokeRoundedFacebook01",
    "Icons.favorite":                                    "HugeIcons.strokeRoundedFavourite",
    "Icons.favorite_border":                             "HugeIcons.strokeRoundedFavourite",
    "Icons.favorite_outline":                            "HugeIcons.strokeRoundedFavourite",
    "Icons.flag":                                        "HugeIcons.strokeRoundedFlag01",
    "Icons.forum":                                       "HugeIcons.strokeRoundedMessage01",
    "Icons.forum_outlined":                              "HugeIcons.strokeRoundedMessage01",
    "Icons.gesture_rounded":                             "HugeIcons.strokeRoundedHandPointingRight01",
    "Icons.g_mobiledata":                                "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.grid_view_outlined":                          "HugeIcons.strokeRoundedGridView",
    "Icons.grid_view_rounded":                           "HugeIcons.strokeRoundedGridView",
    "Icons.help_outline":                                "HugeIcons.strokeRoundedHelpCircle",
    "Icons.history":                                     "HugeIcons.strokeRoundedClock01",
    "Icons.holiday_village_outlined":                    "HugeIcons.strokeRoundedHome08",
    "Icons.home":                                        "HugeIcons.strokeRoundedHome01",
    "Icons.home_filled":                                 "HugeIcons.strokeRoundedHome01",
    "Icons.home_outlined":                               "HugeIcons.strokeRoundedHome01",
    "Icons.home_rounded":                                "HugeIcons.strokeRoundedHome01",
    "Icons.image":                                       "HugeIcons.strokeRoundedImage01",
    "Icons.image_not_supported":                         "HugeIcons.strokeRoundedImageNotFound01",
    "Icons.image_not_supported_outlined":                "HugeIcons.strokeRoundedImageNotFound01",
    "Icons.info_outline":                                "HugeIcons.strokeRoundedInformationCircle",
    "Icons.info_outline_rounded":                        "HugeIcons.strokeRoundedInformationCircle",
    "Icons.inventory_2_outlined":                        "HugeIcons.strokeRoundedPackageAdd",
    "Icons.language":                                    "HugeIcons.strokeRoundedInternet",
    "Icons.local_shipping_outlined":                     "HugeIcons.strokeRoundedTruck",
    "Icons.location_off":                                "HugeIcons.strokeRoundedLocationOffline01",
    "Icons.location_off_outlined":                       "HugeIcons.strokeRoundedLocationOffline01",
    "Icons.location_on":                                 "HugeIcons.strokeRoundedLocation01",
    "Icons.location_on_outlined":                        "HugeIcons.strokeRoundedLocation01",
    "Icons.location_on_rounded":                         "HugeIcons.strokeRoundedLocation01",
    "Icons.location_pin":                                "HugeIcons.strokeRoundedLocation01",
    "Icons.lock_outline":                                "HugeIcons.strokeRoundedLock",
    "Icons.logout_rounded":                              "HugeIcons.strokeRoundedLogout01",
    "Icons.mark_email_read_outlined":                    "HugeIcons.strokeRoundedMailOpen01",
    "Icons.money":                                       "HugeIcons.strokeRoundedMoney01",
    "Icons.notifications_active_outlined":               "HugeIcons.strokeRoundedNotification01",
    "Icons.notifications_none":                          "HugeIcons.strokeRoundedNotification01",
    "Icons.notifications_none_outlined":                 "HugeIcons.strokeRoundedNotification01",
    "Icons.notifications_off_outlined":                  "HugeIcons.strokeRoundedNotificationOff01",
    "Icons.notifications_outlined":                      "HugeIcons.strokeRoundedNotification01",
    "Icons.payment":                                     "HugeIcons.strokeRoundedCreditCard",
    "Icons.person":                                      "HugeIcons.strokeRoundedUser",
    "Icons.person_outline":                              "HugeIcons.strokeRoundedUser",
    "Icons.person_outline_rounded":                      "HugeIcons.strokeRoundedUser",
    "Icons.phone":                                       "HugeIcons.strokeRoundedCall",
    "Icons.phone_android":                               "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.phone_android_outlined":                      "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.phone_android_rounded":                       "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.phone_outlined":                              "HugeIcons.strokeRoundedCall",
    "Icons.public":                                      "HugeIcons.strokeRoundedGlobe",
    "Icons.qr_code":                                     "HugeIcons.strokeRoundedQrCode01",
    "Icons.radio_button_off":                            "HugeIcons.strokeRoundedCircle",
    "Icons.rate_review_outlined":                        "HugeIcons.strokeRoundedComment01",
    "Icons.remove":                                      "HugeIcons.strokeRoundedRemove01",
    "Icons.satellite_alt_rounded":                       "HugeIcons.strokeRoundedSatellite01",
    "Icons.search":                                      "HugeIcons.strokeRoundedSearch01",
    "Icons.search_off":                                  "HugeIcons.strokeRoundedSearchRemove",
    "Icons.security":                                    "HugeIcons.strokeRoundedShield01",
    "Icons.sell_outlined":                               "HugeIcons.strokeRoundedTag01",
    "Icons.send":                                        "HugeIcons.strokeRoundedSent",
    "Icons.settings_outlined":                           "HugeIcons.strokeRoundedSettings01",
    "Icons.share_outlined":                              "HugeIcons.strokeRoundedShare01",
    "Icons.shopping_bag":                                "HugeIcons.strokeRoundedShoppingBag01",
    "Icons.shopping_bag_outlined":                       "HugeIcons.strokeRoundedShoppingBag01",
    "Icons.shopping_cart_outlined":                      "HugeIcons.strokeRoundedShoppingCart01",
    "Icons.signal_cellular_connected_no_internet_4_bar_rounded": "HugeIcons.strokeRoundedCellularNetworkOffline",
    "Icons.signpost_outlined":                           "HugeIcons.strokeRoundedRoadLocation01",
    "Icons.smartphone":                                  "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.smartphone_outlined":                         "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.star":                                        "HugeIcons.strokeRoundedStars",
    "Icons.star_border":                                 "HugeIcons.strokeRoundedStars",
    "Icons.straighten_rounded":                          "HugeIcons.strokeRoundedRuler",
    "Icons.style_outlined":                              "HugeIcons.strokeRoundedPaintBoard",
    "Icons.thumb_up_alt_outlined":                       "HugeIcons.strokeRoundedThumbsUp",
    "Icons.tune":                                        "HugeIcons.strokeRoundedFilter",
    "Icons.verified":                                    "HugeIcons.strokeRoundedCheckmarkBadge01",
    "Icons.videocam_outlined":                           "HugeIcons.strokeRoundedVideo01",
    "Icons.visibility":                                  "HugeIcons.strokeRoundedView",
    "Icons.visibility_off":                              "HugeIcons.strokeRoundedViewOff",
    "Icons.wallet_outlined":                             "HugeIcons.strokeRoundedWallet01",
    "Icons.wb_sunny_outlined":                           "HugeIcons.strokeRoundedSun01",
    "Icons.wifi_off_rounded":                            "HugeIcons.strokeRoundedWifiOff01",
    "Icons.work":                                        "HugeIcons.strokeRoundedBriefcase01",
    "Icons.work_rounded":                                "HugeIcons.strokeRoundedBriefcase01",
}

IMPORT_LINE = "import 'package:hugeicons/hugeicons.dart';"


def add_import_if_needed(content):
    if IMPORT_LINE in content:
        return content
    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith("import "):
            last_import_idx = i
    if last_import_idx == -1:
        return IMPORT_LINE + '\n' + content
    lines.insert(last_import_idx + 1, IMPORT_LINE)
    return '\n'.join(lines)


def find_balanced_end(content, start):
    """
    Given that content[start-1] == '(', find the position after the matching ')'.
    """
    depth = 1
    i = start
    in_string = False
    string_char = None
    while i < len(content) and depth > 0:
        ch = content[i]
        if in_string:
            if ch == '\\':
                i += 2
                continue
            if ch == string_char:
                in_string = False
        else:
            if ch in ('"', "'"):
                in_string = True
                string_char = ch
            elif ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
        i += 1
    return i  # position after the closing ')'


def parse_icon_args(args_str):
    """
    Parse the arguments inside Icon(...).
    Returns (icon_key, color_expr, size_expr).
    icon_key is like 'Icons.home' (stripped of 'const ')
    """
    s = args_str.strip()
    # Find first comma at depth 0
    depth = 0
    first_comma = -1
    for i, ch in enumerate(s):
        if ch in '([{':
            depth += 1
        elif ch in ')]}':
            depth -= 1
        elif ch == ',' and depth == 0:
            first_comma = i
            break

    if first_comma == -1:
        icon_str = s.strip().replace('const ', '')
        return icon_str, None, None

    icon_str = s[:first_comma].strip().replace('const ', '')
    rest = s[first_comma + 1:]

    color = None
    size = None

    # Extract named params from rest using depth-tracking
    # Named params: color: ..., size: ...
    def extract_named_param(text, param_name):
        pattern = re.compile(r'\b' + param_name + r'\s*:\s*')
        m = pattern.search(text)
        if not m:
            return None
        start = m.end()
        depth = 0
        end = start
        while end < len(text):
            ch = text[end]
            if ch in '([{':
                depth += 1
            elif ch in ')]}':
                if depth == 0:
                    break
                depth -= 1
            elif ch == ',' and depth == 0:
                break
            end += 1
        return text[start:end].strip()

    color = extract_named_param(rest, 'color')
    size = extract_named_param(rest, 'size')

    return icon_str, color, size


def replace_icons_in_content(content):
    """
    Find all Icon(Icons.xxx) calls and replace with HugeIcon(icon: HugeIcons.xxx, color: c, size: s,)
    """
    result = []
    i = 0
    changed = False
    n = len(content)

    while i < n:
        # Search for Icon( not preceded by a word character (to avoid HugeIcon, NavItem, etc.)
        m = re.search(r'(?<![A-Za-z0-9_])(const\s+)?Icon\(', content[i:])
        if not m:
            result.append(content[i:])
            break

        match_start = i + m.start()
        paren_start = i + m.end()  # position right after the '('

        # Append everything before this match
        result.append(content[i:match_start])

        # Find the matching closing paren
        end_pos = find_balanced_end(content, paren_start)

        # Get args inside Icon(...)
        args_str = content[paren_start:end_pos - 1]

        icon_key, color, size = parse_icon_args(args_str)

        if icon_key in ICON_MAP:
            huge_icon = ICON_MAP[icon_key]
            color_str = color if color else 'Colors.black'
            size_str = size if size else '24.0'
            replacement = f'HugeIcon(icon: {huge_icon}, color: {color_str}, size: {size_str},)'
            result.append(replacement)
            changed = True
        else:
            # Keep as-is
            result.append(content[match_start:end_pos])

        i = end_pos

    if not changed:
        return None

    new_content = ''.join(result)
    new_content = add_import_if_needed(new_content)
    return new_content


def process_directory(lib_dir):
    changed_files = []
    for root, dirs, files in os.walk(lib_dir):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for fname in files:
            if not fname.endswith('.dart'):
                continue
            path = os.path.join(root, fname)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()

            if 'Icons.' not in content:
                continue

            new_content = replace_icons_in_content(content)
            if new_content is not None:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                changed_files.append(path)

    return changed_files


if __name__ == '__main__':
    lib_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'lib')
    changed = process_directory(lib_dir)
    print(f"✅ Migration terminée. {len(changed)} fichier(s) modifié(s):")
    for p in changed:
        rel = os.path.relpath(p, lib_dir)
        print(f"   - {rel}")
