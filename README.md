rdiff-backup-qnap-script
========================

Skript kann direkt auf der Qnap ausgeführt werden und versendet von dort Status E-Mails

Das Script benötigt im selben Verzeichniss eine globbing-filelist.
Die datei wird nach dem backupserver mit dem zusatz .list benannt.
Hier im Beispiel mein.server.tld.list

Zur verwendung der globbing-filelist hier mehr
http://rdiff-backup.nongnu.org/examples.html

Als Beispiel noch der Inhalt einer globbing-filelist um einen Debian Wheezy Webserver zu sichern

- /tmp 
- /mnt
- /proc
- /root
+ /root/scripts
- /dev 
- /cdrom 
- /sys
- /var/run
- /backup
- /home/
- /var/log
