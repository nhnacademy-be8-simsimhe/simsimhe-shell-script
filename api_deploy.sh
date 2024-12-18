source variables

SERVICE_PORT="8010"
TMP_PORT="8011"
ip="127.0.0.1"

echo -e "$ip:$SERVICE_PORT의 api-server를 종료합니다."
fuser -s -k -TERM $SERVICE_PORT/tcp
sleep 5

echo -e "$ip:$SERVICE_PORT에 api-server를 실행시킵니다."
nohup java -jar -Dserver.port=${SERVICE_PORT} -DLOG_N_CRASH_APP_KEY=${LOG_N_CRASH_APP_KEY} -Dspring.profiles.active=prod ~/target/simsimhe-shop-api-server-0.0.1-SNAPSHOT.jar &
sleep 5

echo -e "$ip:$TMP_PORT의 api-server를 종료합니다."
fuser -s -k -TERM $SERVICE_PORT/tcp
sleep 5



