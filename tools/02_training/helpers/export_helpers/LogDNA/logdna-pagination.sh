#!/bin/bash
# From here https://github.ibm.com/AIOps-Elite-Team/logs-extractors/blob/master/logdna-pagination.sh
set -e

# Constants
SERVICE_KEY=""
LOGDNA_ENDPOINT="api.us-east.logging.cloud.ibm.com/v1/export"
QUERY="namespace%3Asock-shop"
LOGS_FILE="sock-shop.logs"
TMP_LOGS_FILE="${LOGS_FILE}.tmp"
MAX_LOG_LINES_PER_CALL=10000
# Let's get 4M log lines
MAX_NUMBER_LOG_LINES_TO_EXTRACT=4000000
LINES_PER_FILE=1000000
# Number of days from current date/time (to compute start time)
NUMBER_OF_DAYS=5
SECONDS_IN_DAY=86400
OUTPUT_DIR=$(date '+%Y-%m-%d-%H-%M-%S')

mkdir "${OUTPUT_DIR}"
pushd "${OUTPUT_DIR}"

# Variables
# 86400 seconds in 1 day
start_time=$(($(date +%s)-(${NUMBER_OF_DAYS} * ${SECONDS_IN_DAY})))000
end_time=$(date +%s)000
number_of_lines=0
total_number_of_lines=0

while [ ${total_number_of_lines} -le ${MAX_NUMBER_LOG_LINES_TO_EXTRACT} ]
do
  echo "start_time: ${start_time}"
  number_of_lines=$(curl "https://${LOGDNA_ENDPOINT}?from=${start_time}&to=${end_time}&prefer=head&size=${MAX_LOG_LINES_PER_CALL}&query=${QUERY}" -u ${SERVICE_KEY}: 2>/dev/null | tee -a ${TMP_LOGS_FILE} | wc -l)
  total_number_of_lines=$(cat ${TMP_LOGS_FILE} | wc -l)
  echo "total_number_of_lines: ${total_number_of_lines}"
  echo "number_of_lines: ${number_of_lines}"
  start_time=$(tail -n 1 ${TMP_LOGS_FILE} | jq '._ts' )
  if [[ ${number_of_lines} -lt ${MAX_LOG_LINES_PER_CALL} ]]; then
    echo "Breaking from loop..."
    break
  fi
done

# Eliminate dups
echo "Eliminating dups... this may take a while..."
total_number_of_lines=$(awk '!seen[$0]++' ${TMP_LOGS_FILE} | tee ${LOGS_FILE} | wc -l)
echo "Dups removed."
echo "Actual total number of lines: ${total_number_of_lines}"

# Split 
echo "Splitting into multiple files..."
split -l ${LINES_PER_FILE} ${LOGS_FILE} ${LOGS_FILE}

echo "Done!"

popd