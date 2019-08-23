#!/bin/sh

FILENAME="fbpac-archive-$(date +%Y-%m-%d)"

if [[ -z $DATABASE_URL || -z $ARCHIVE_BUCKET ]]; then
    printf "One or more required variables missing:\n"
    printf "\tDATABASE_URL\n\tARCHIVE_BUCKET\n"
    exit 1
fi

echo "$(date -u) starting postgres export" &&
    psql "${DATABASE_URL}" -c "\COPY (SELECT * FROM ads WHERE (paid_for_by is not null or political_probability > 0.7) AND suppressed=false) to '${FILENAME}.csv' with csv header" &&
    echo "$(date -u) compressing ${FILENAME}.csv to ${FILENAME}.tar.gz" &&
    tar -cvzf "${FILENAME}.tar.gz" "${FILENAME}.csv" &&
    echo "$(date -u) copying ${FILENAME}.tar.gz to s3://${ARCHIVE_BUCKET}" &&
    aws s3 cp --acl public-read "${FILENAME}.tar.gz" s3://${ARCHIVE_BUCKET}/ &&
    echo "$(date -u) copying s3://${ARCHIVE_BUCKET}/${FILENAME}.tar.gz to s3://${ARCHIVE_BUCKET}/fbpac-archive-latest.tar.gz" &&
    aws s3 cp --acl public-read s3://${ARCHIVE_BUCKET}/${FILENAME}.tar.gz s3://${ARCHIVE_BUCKET}/fbpac-archive-latest.tar.gz
