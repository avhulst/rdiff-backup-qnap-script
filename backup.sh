#!/bin/bash
# rdiff-backup Skript für Qnap von Andreas van Hulst auf Basis von http://www.renier.de/blog/backupderdatenmitrdiff-backup
# Script kann nun auf einer Qnap ausgeführt werden und Remote Server sichern

#Backup Einstellungen
SSHUSER="root"
BACKUPSERVER="mein.server.tld"
REPORTMAILTO="andreas@vanhulst.de"                             
REPORTMAILFROM="backup@vanhulst.de"
REMOTEBACKUPPATH=/home
LOCALBACKUPPATH=./
SUBJECT="rdiff-backup $BACKUPSERVER"
OLDERTHAN=1W

#Hier bitte nur anpassen wenn anders nicht möglich
DATUM="$(date +%d.%m.%Y)"
SOURCE=$SSHUSER@$BACKUPSERVER::$REMOTEBACKUPPATH
DEST=$LOCALBACKUPPATH$BACKUPSERVER

#Scriptstartzeit in Variable zum berechen der Dauer des Backups
START=$(date +%s)

#Mail Function für Status E-Mails
mailme () {
   /usr/sbin/sendmail -t <<EOM
Subject: $SUBJECT - $SUBJECT2
To: $REPORTMAILTO
From: $REPORTMAILFROM

$MESSAGE
EOM
		 
}

### Test ob Backupverzeichnis existiert und Mail an Admin bei fehlschlagen
if [ ! -d "${DEST}" ]; then
SUBJECT2=" Backupverzeichnis nicht vorhanden!" 
MESSAGE="Hallo,

das Backup von ${BACKUPSERVER} am ${DATUM} konnte nicht erstellt werden. 
Das Verzeichnis ${TARGET} wurde nicht gefunden und konnte auch nicht angelegt werden.

Mit freundlichem Gruss 
Backupscript"
mailme
 exit 1
fi

# Backup durchführen
rdiff-backup -v5 --print-statistics --include-globbing-filelist $BACKUPSERVER.list $SOURCE $DEST

# erfolgreich falls nicht mail
if [ $? -ne 0 ]; then
SUBJECT2=" fehlerhaft!" 
MESSAGE="Hallo,

das Backup von ${BACKUPSERVER} konnte am ${DATUM} nicht erstellt werden.

Mit freundlichem Gruss 
Backupscript"
mailme
  exit 1 
fi

rdiff-backup --remove-older-than $OLDERTHAN --force $DEST
if [ $? -ne 0 ]; then
SUBJECT2=" fehler beim loeschen der alten Backupdaten!" 
MESSAGE="Hallo,

die alten Backupdaten von ${BACKUPSERVER} konnte am ${DATUM} nicht geloescht werden.

Mit freundlichem Gruss 
Backupscript"
mailme
  exit 1
fi

ENDE=$(date +%s)
SCRIPTDAUER=$(($ENDE - $START))
STD=$((SCRIPTDAUER /3600))
MIN=$((SCRIPTDAUER % 3600 /60))
SEC=$((SCRIPTDAUER % 60))
MSG=`rdiff-backup --list-increments $DEST`
SUBJECT2=" erfolgreich!" 
MESSAGE="Hallo,

die Backup von ${BACKUPSERVER} wurde am ${DATUM} erfolgreich fertiggestellt.
Backupdauer $STD Stunden $MIN Minuten und  $SEC Sekunden

Mit freundlichem Gruss 
Backupscript

====================================
$MSG
"
mailme

exit 0
