import os

plist_path = 'ios/Runner/Info.plist'
if os.path.exists(plist_path):
    with open(plist_path, 'r', encoding='utf-8') as f:
        content = f.read()

    if '<key>NSCameraUsageDescription</key>' not in content:
        privacy_tags = """\t<key>CFBundleDisplayName</key>
\t<string>إتقان</string>
\t<key>NSCameraUsageDescription</key>
\t<string>يحتاج تطبيق إتقان إلى إذن الكاميرا للمشاركة في حلقات التلاوة وتصحيح القرآن بالفيديو مع فضيلة الشيخ.</string>
\t<key>NSMicrophoneUsageDescription</key>
\t<string>يحتاج تطبيق إتقان إلى إذن الميكروفون لتسميع القرآن الكريم والمشاركة الصوتية في الحلقات المباشرة.</string>
\t<key>NSPhotoLibraryUsageDescription</key>
\t<string>يحتاج تطبيق إتقان إلى إذن مكتبة الصور لتغيير الصورة الشخصية ورفع المستندات.</string>
\t<key>UIBackgroundModes</key>
\t<array>
\t\t<string>audio</string>
\t</array>
\t<key>CFBundleURLTypes</key>
\t<array>
\t\t<dict>
\t\t\t<key>CFBundleTypeRole</key>
\t\t\t<string>Editor</string>
\t\t\t<key>CFBundleURLName</key>
\t\t\t<string>com.etqan.app</string>
\t\t\t<key>CFBundleURLSchemes</key>
\t\t\t<array>
\t\t\t\t<string>etqan</string>
\t\t\t</array>
\t\t</dict>
\t</array>
</dict>"""
        content = content.replace('</dict>', privacy_tags, 1)
        with open(plist_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Updated ios/Runner/Info.plist with App Store privacy descriptions successfully.")
else:
    print("ios/Runner/Info.plist not found.")
