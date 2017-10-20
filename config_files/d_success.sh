tail --follow=name /mnt/STORJ01/storjlogs/*.log | awk '/^==> / {a=substr($0, 29, 40); next} {print a":"$0}' | grep -i "download completed\|upload completed"
