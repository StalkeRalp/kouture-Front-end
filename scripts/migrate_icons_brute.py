import os
import re

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

def process_directory(lib_dir):
    changed_files = []
    for root, dirs, files in os.walk(lib_dir):
        for fname in files:
            if not fname.endswith('.dart'):
                continue
            path = os.path.join(root, fname)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()

            orig_content = content

            # Fix Icons.strokeRounded -> HugeIcons.strokeRounded
            content = re.sub(r'Icons\.strokeRounded', r'HugeIcons.strokeRounded', content)

            # Replace any Icons.xxx that matches ICON_MAP
            for old_icon, new_icon in ICON_MAP.items():
                content = re.sub(r'\b' + old_icon.replace('.', r'\.') + r'\b', new_icon, content)

            # Change IconData to dynamic everywhere except in Flutter SDK imports (which aren't here)
            # This makes sure custom widgets accept HugeIcons
            content = re.sub(r'\bIconData\b', 'dynamic', content)

            if content != orig_content:
                # add import if it has HugeIcons but not the import
                if 'HugeIcons.' in content and 'import \'package:hugeicons/hugeicons.dart\';' not in content:
                    lines = content.split('\n')
                    last_import_idx = -1
                    for i, line in enumerate(lines):
                        if line.strip().startswith("import "):
                            last_import_idx = i
                    if last_import_idx != -1:
                        lines.insert(last_import_idx + 1, "import 'package:hugeicons/hugeicons.dart';")
                        content = '\n'.join(lines)
                    else:
                        content = "import 'package:hugeicons/hugeicons.dart';\n" + content

                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)
                changed_files.append(path)

    return changed_files

if __name__ == '__main__':
    lib_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'lib')
    changed = process_directory(lib_dir)
    print(f"✅ Migration brute terminée. {len(changed)} fichier(s) modifié(s)")
