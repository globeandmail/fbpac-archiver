#!/bin/sh

FILENAME="fbpac-archive-$(date +%Y-%m-%d)"

if [[ -z $DATABASE_URL || -z $ARCHIVE_BUCKET ]]; then
    printf "One or more required variables missing:\n"
    printf "\tDATABASE_URL\n\tARCHIVE_BUCKET\n"
    exit 1
fi

psql "${DATABASE_URL}" -c "\COPY (SELECT * FROM ads WHERE (paid_for_by is not null or political_probability > 0.7) AND suppressed=false) to '${FILENAME}.csv' with csv header" &&
    tar -cvzf "${FILENAME}.tar.gz" "${FILENAME}.csv" &&
    aws s3 cp --acl public-read "${FILENAME}.tar.gz" s3://${ARCHIVE_BUCKET}/ &&
    rm "${FILENAME}.csv" "${FILENAME}.tar.gz"
