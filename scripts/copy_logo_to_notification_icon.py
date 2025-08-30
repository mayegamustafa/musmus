# This script copies logo.png to the notification icon for Android notifications
import shutil
import os

src = os.path.join(os.path.dirname(__file__), '..', '..', 'logo.png')
dst = os.path.join(os.path.dirname(__file__), '..', 'android', 'app', 'src', 'main', 'res', 'drawable', 'notification_icon.png')

shutil.copyfile(src, dst)
print(f'Copied {src} to {dst}')
