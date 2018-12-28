#!/bin/bash

DESTINATION_ADDRESS='root@192.168.56.2'

# Dump database contents
echo "Exporting imaging database..."
echo "set FOREIGN_KEY_CHECKS = 0;" > imaging.sql
echo "START TRANSACTION;" >> imaging.sql
mysqldump --compact --complete-insert --no-create-info --where='id>=13' imaging BootService |grep ^INSERT >> imaging.sql
mysqldump --compact --complete-insert --no-create-info --where='id>=1000' imaging PostInstallScript |grep ^INSERT >> imaging.sql
mysqldump --compact --complete-insert --no-create-info imaging BootServiceOnImagingServer PostInstallScriptOnImagingServer |grep ^INSERT >> imaging.sql
mysqldump --compact --complete-insert --no-create-info --where='is_master=1' imaging Image |grep ^INSERT >> imaging.sql
mysqldump --compact --complete-insert --no-create-info imaging ImageOnImagingServer |grep ^INSERT >> imaging.sql
mysqldump --compact --complete-insert --no-create-info --lock-all-tables --where='fk_image in (select id from Image where is_master=1)' imaging MasteredOn |grep ^INSERT >> imaging.sql
echo "UPDATE MasteredOn set fk_imaging_log=1;" >> imaging.sql
echo "COMMIT;" >> imaging.sql
echo "set FOREIGN_KEY_CHECKS = 1;" >> imaging.sql

# Copy masters
echo "Copying masters..."
PATHS=$(echo 'SELECT path FROM Image WHERE is_master=1;' | mysql imaging)
readarray MASTER <<<"$PATHS"
for (( i=1; i<=$(( ${#MASTER[@]}-1 )); i++ ))
do
	rsync -av ${MASTER[$i]} ${DESTINATION_ADDRESS}:/var/lib/pulse2/imaging/masters/
done

# Copy drivers
echo "Copying drivers..."
rsync -av /var/lib/pulse2/imaging/postinst/sysprep/drivers/* ${DESTINATION_ADDRESS}:/var/lib/pulse2/imaging/postinst/sysprep/drivers/

# Copy sysprep files
echo "Copying sysprep files..."
scp /var/lib/pulse2/imaging/postinst/sysprep/*.xml ${DESTINATION_ADDRESS}:/var/lib/pulse2/imaging/postinst/sysprep/

# End tasks
scp imaging.sql ${DESTINATION_ADDRESS}:/root
echo "/root/imaging.sql needs to be imported to imaging database on target Pulse"
