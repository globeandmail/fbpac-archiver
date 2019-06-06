FILENAME="dump-`date +%Y-%m-%d`"
psql "${DATABASE_URL}" -c "\COPY (SELECT * FROM ads WHERE (paid_for_by is not null or political_probability > 0.7) AND suppressed=false) to '${FILENAME}.csv' with csv header"
tar -cvzf "${FILENAME}.tar.gz" "${FILENAME}.csv"
aws s3 cp --acl public-read "${FILENAME}.tar.gz" s3://${ARCHIVE_URL}/

rm "${FILENAME}.csv"
rm "${FILENAME}.tar.gz"
