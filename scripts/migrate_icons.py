#!/usr/bin/env python3
"""
Script de migration : remplace tous les Icons.xxx de Material par HugeIcons
"""

import os
import re

# Mapping : Icons.xxx -> HugeIcons.strokeRoundedXxx (équivalent le plus proche)
ICON_MAP = {
    # Navigation
    "Icons.home": "HugeIcons.strokeRoundedHome01",
    "Icons.home_outlined": "HugeIcons.strokeRoundedHome01",
    "Icons.home_filled": "HugeIcons.strokeRoundedHome01",
    "Icons.home_rounded": "HugeIcons.strokeRoundedHome01",
    "Icons.person": "HugeIcons.strokeRoundedUser",
    "Icons.person_outline": "HugeIcons.strokeRoundedUser",
    "Icons.person_outline_rounded": "HugeIcons.strokeRoundedUser",
    "Icons.grid_view_outlined": "HugeIcons.strokeRoundedGrid01",
    "Icons.grid_view_rounded": "HugeIcons.strokeRoundedGrid01",
    "Icons.favorite": "HugeIcons.strokeRoundedFavourite",
    "Icons.favorite_outline": "HugeIcons.strokeRoundedFavourite",
    "Icons.favorite_border": "HugeIcons.strokeRoundedFavourite",
    "Icons.forum": "HugeIcons.strokeRoundedMessage01",
    "Icons.forum_outlined": "HugeIcons.strokeRoundedMessage01",
    # Recherche
    "Icons.search": "HugeIcons.strokeRoundedSearch01",
    "Icons.search_off": "HugeIcons.strokeRoundedSearchRemove",
    # Flèches & Navigation
    "Icons.arrow_back": "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.arrow_back_ios_new": "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.arrow_back_rounded": "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.arrow_forward": "HugeIcons.strokeRoundedArrowRight01",
    "Icons.arrow_forward_ios": "HugeIcons.strokeRoundedArrowRight01",
    "Icons.chevron_left": "HugeIcons.strokeRoundedArrowLeft01",
    "Icons.chevron_right": "HugeIcons.strokeRoundedArrowRight01",
    # Panier / Shopping
    "Icons.shopping_bag": "HugeIcons.strokeRoundedShoppingBag01",
    "Icons.shopping_bag_outlined": "HugeIcons.strokeRoundedShoppingBag01",
    "Icons.shopping_cart_outlined": "HugeIcons.strokeRoundedShoppingCart01",
    "Icons.add_shopping_cart": "HugeIcons.strokeRoundedShoppingCartAdd",
    # Actions courantes
    "Icons.add": "HugeIcons.strokeRoundedAdd01",
    "Icons.remove": "HugeIcons.strokeRoundedRemove01",
    "Icons.close": "HugeIcons.strokeRoundedCancel01",
    "Icons.close_rounded": "HugeIcons.strokeRoundedCancel01",
    "Icons.clear": "HugeIcons.strokeRoundedCancel01",
    "Icons.check": "HugeIcons.strokeRoundedTick01",
    "Icons.check_circle": "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.check_circle_outline": "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.check_circle_outline_rounded": "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.check_circle_rounded": "HugeIcons.strokeRoundedCheckmarkCircle01",
    "Icons.delete_outline": "HugeIcons.strokeRoundedDelete01",
    "Icons.edit": "HugeIcons.strokeRoundedEdit01",
    "Icons.edit_outlined": "HugeIcons.strokeRoundedEdit01",
    "Icons.send": "HugeIcons.strokeRoundedSent",
    "Icons.share_outlined": "HugeIcons.strokeRoundedShare01",
    "Icons.tune": "HugeIcons.strokeRoundedFilter",
    "Icons.download_outlined": "HugeIcons.strokeRoundedDownload01",
    # Localisation / Carte
    "Icons.location_on": "HugeIcons.strokeRoundedLocation01",
    "Icons.location_on_outlined": "HugeIcons.strokeRoundedLocation01",
    "Icons.location_on_rounded": "HugeIcons.strokeRoundedLocation01",
    "Icons.location_pin": "HugeIcons.strokeRoundedLocation01",
    "Icons.location_off": "HugeIcons.strokeRoundedLocationOff01",
    "Icons.location_off_outlined": "HugeIcons.strokeRoundedLocationOff01",
    "Icons.satellite_alt_rounded": "HugeIcons.strokeRoundedSatellite01",
    # Notifications
    "Icons.notifications_none": "HugeIcons.strokeRoundedNotification01",
    "Icons.notifications_none_outlined": "HugeIcons.strokeRoundedNotification01",
    "Icons.notifications_outlined": "HugeIcons.strokeRoundedNotification01",
    "Icons.notifications_active_outlined": "HugeIcons.strokeRoundedNotificationSquare",
    "Icons.notifications_off_outlined": "HugeIcons.strokeRoundedNotificationOff01",
    # Communication
    "Icons.call_outlined": "HugeIcons.strokeRoundedCall",
    "Icons.phone": "HugeIcons.strokeRoundedCall",
    "Icons.phone_outlined": "HugeIcons.strokeRoundedCall",
    "Icons.phone_android": "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.phone_android_outlined": "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.phone_android_rounded": "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.smartphone": "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.smartphone_outlined": "HugeIcons.strokeRoundedSmartPhone01",
    "Icons.chat_bubble_outline": "HugeIcons.strokeRoundedBubbleChatQuestion",
    "Icons.comment": "HugeIcons.strokeRoundedComment01",
    "Icons.videocam_outlined": "HugeIcons.strokeRoundedVideo01",
    # Email
    "Icons.email_outlined": "HugeIcons.strokeRoundedMail01",
    "Icons.mark_email_read_outlined": "HugeIcons.strokeRoundedMailOpen01",
    # Paramètres / Sécurité
    "Icons.settings_outlined": "HugeIcons.strokeRoundedSettings01",
    "Icons.lock_outline": "HugeIcons.strokeRoundedLock01",
    "Icons.security": "HugeIcons.strokeRoundedShield01",
    "Icons.visibility": "HugeIcons.strokeRoundedView",
    "Icons.visibility_off": "HugeIcons.strokeRoundedViewOff",
    "Icons.logout_rounded": "HugeIcons.strokeRoundedLogout01",
    "Icons.language": "HugeIcons.strokeRoundedInternet",
    "Icons.public": "HugeIcons.strokeRoundedGlobe01",
    # Info & Aides
    "Icons.help_outline": "HugeIcons.strokeRoundedHelpCircle",
    "Icons.info_outline": "HugeIcons.strokeRoundedInformationCircle",
    "Icons.info_outline_rounded": "HugeIcons.strokeRoundedInformationCircle",
    "Icons.error_outline": "HugeIcons.strokeRoundedAlertCircle",
    "Icons.error_outline_rounded": "HugeIcons.strokeRoundedAlertCircle",
    "Icons.flag": "HugeIcons.strokeRoundedFlag01",
    # Paiement
    "Icons.payment": "HugeIcons.strokeRoundedCreditCard01",
    "Icons.credit_card": "HugeIcons.strokeRoundedCreditCard01",
    "Icons.wallet_outlined": "HugeIcons.strokeRoundedWallet01",
    "Icons.money": "HugeIcons.strokeRoundedMoney01",
    "Icons.contactless": "HugeIcons.strokeRoundedContactless01",
    # Profil & Utilisateur
    "Icons.camera_alt": "HugeIcons.strokeRoundedCamera01",
    "Icons.add_a_photo_outlined": "HugeIcons.strokeRoundedCameraAdd01",
    "Icons.work": "HugeIcons.strokeRoundedBriefcase01",
    "Icons.work_rounded": "HugeIcons.strokeRoundedBriefcase01",
    # Livraison / Commandes
    "Icons.local_shipping_outlined": "HugeIcons.strokeRoundedTruck01",
    "Icons.inventory_2_outlined": "HugeIcons.strokeRoundedPackageAdd",
    "Icons.sell_outlined": "HugeIcons.strokeRoundedTag01",
    "Icons.analytics_outlined": "HugeIcons.strokeRoundedAnalytics01",
    "Icons.history": "HugeIcons.strokeRoundedClock01",
    "Icons.calendar_today_outlined": "HugeIcons.strokeRoundedCalendar01",
    "Icons.rate_review_outlined": "HugeIcons.strokeRoundedComment01",
    "Icons.thumb_up_alt_outlined": "HugeIcons.strokeRoundedThumbsUp",
    # Images & Médias
    "Icons.image": "HugeIcons.strokeRoundedImage01",
    "Icons.image_not_supported": "HugeIcons.strokeRoundedImageNotFound",
    "Icons.image_not_supported_outlined": "HugeIcons.strokeRoundedImageNotFound",
    "Icons.broken_image": "HugeIcons.strokeRoundedImageNotFound",
    # Divers
    "Icons.star": "HugeIcons.strokeRoundedStar",
    "Icons.star_border": "HugeIcons.strokeRoundedStar",
    "Icons.qr_code": "HugeIcons.strokeRoundedQrCode01",
    "Icons.radio_button_off": "HugeIcons.strokeRoundedCircle",
    "Icons.circle": "HugeIcons.strokeRoundedCircle",
    "Icons.verified": "HugeIcons.strokeRoundedCheckmarkBadge01",
    "Icons.auto_awesome": "HugeIcons.strokeRoundedSparkles",
    "Icons.gesture_rounded": "HugeIcons.strokeRoundedHandPointingRight01",
    "Icons.straighten_rounded": "HugeIcons.strokeRoundedRuler",
    "Icons.style_outlined": "HugeIcons.strokeRoundedPaint01",
    "Icons.cut_outlined": "HugeIcons.strokeRoundedScissors01",
    "Icons.signpost_outlined": "HugeIcons.strokeRoundedRoadLocation01",
    "Icons.cloud_off": "HugeIcons.strokeRoundedCloudOff",
    "Icons.wifi_off_rounded": "HugeIcons.strokeRoundedWifiOff01",
    "Icons.signal_cellular_connected_no_internet_4_bar_rounded": "HugeIcons.strokeRoundedNoCellular",
    "Icons.wb_sunny_outlined": "HugeIcons.strokeRoundedSun01",
    "Icons.holiday_village_outlined": "HugeIcons.strokeRoundedHome08",
    "Icons.g_mobiledata": "HugeIcons.strokeRoundedMobileData01",
    "Icons.facebook": "HugeIcons.strokeRoundedFacebook01",
    "Icons.download_outlined": "HugeIcons.strokeRoundedDownload01",
}

IMPORT_LINE = "import 'package:hugeicons/hugeicons.dart';"

def add_import_if_needed(content, filepath):
    if IMPORT_LINE in content:
        return content
    # Inserting after the first import line
    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith("import "):
            last_import_idx = i
    if last_import_idx != -1:
        lines.insert(last_import_idx + 1, IMPORT_LINE)
    return '\n'.join(lines)

def replace_icons(content):
    # Sort by length of key descending so longer specific keys match first
    for old, new in sorted(ICON_MAP.items(), key=lambda x: -len(x[0])):
        # Escape and match as whole word
        pattern = re.escape(old) + r'(?=[,\s\)])'
        content = re.sub(pattern, new, content)
    return content

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        original = f.read()
    
    # Only process if Icons. appears
    if 'Icons.' not in original:
        return False
    
    modified = replace_icons(original)
    
    if modified != original:
        modified = add_import_if_needed(modified, filepath)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(modified)
        return True
    return False

def main():
    lib_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'lib')
    changed = []
    for root, dirs, files in os.walk(lib_dir):
        # Skip hidden dirs
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for fname in files:
            if fname.endswith('.dart'):
                path = os.path.join(root, fname)
                if process_file(path):
                    changed.append(path)
    
    print(f"✅ Migration terminée. {len(changed)} fichier(s) modifié(s):")
    for p in changed:
        print(f"   - {os.path.relpath(p, lib_dir)}")

if __name__ == '__main__':
    main()
