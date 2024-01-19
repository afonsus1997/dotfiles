
#!/bin/bash 
# /usr/bin/blurlock

# take screenshot
import -window root /tmp/screenshot.png

# blur it 
convert /tmp/screenshot.png -blur 0x5 /tmp/screenblur.png
rm /tmp/screenshot.png

i3lock -i /tmp/screenblur.png

sleep 1

exit 0
