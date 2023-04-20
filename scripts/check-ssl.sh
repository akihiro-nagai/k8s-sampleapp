#!/bin/bash
# Usage: ./check-ssl.sh <staging|production>
set -o pipefail

env=${1}

ALERT_THRESHOLD_IN_DAYS=7

STG_URLS="twitter.com"

PROD_URLS="google.com"

case ${env} in
  'staging')
    urls=${STG_URLS}
    ;;
  'production')
    urls=${PROD_URLS}
    ;;
  *)
    echo "Unknown environment: ${env}"
    exit 1
    ;;
esac

alert_msg=""

for url in ${urls}; do
  expire_at=$(timeout 5 openssl s_client -connect ${url}:443 </dev/null 2>/dev/null | openssl x509 -noout -enddate | cut -d '=' -f 2)
  ret=$?
  if [[ ${ret} != 0 ]]; then
    alert_msg+="* ${url} 証明書情報の取得に失敗しました\n"
    continue
  fi

  expire_date=$(date '+%Y%m%d' --date="${expire_at}")
  alert_date=$(date '+%Y%m%d' -d "${ALERT_THRESHOLD_IN_DAYS} days")

  if [[ ${expire_date} < ${alert_date} ]]; then
    alert_msg+="* ${url} (有効期限: ${expire_at})\n"
  fi
done

if [[ -n ${alert_msg} ]]; then
  echo -n "SSL の証明書有効期限が残り ${ALERT_THRESHOLD_IN_DAYS} 日を切っている証明書が検出されました！\n"
  echo -n "${alert_msg}"
fi
