source ~/variables

SERVICE_PORT="8010"
TMP_PORT="8011"
ip="127.0.0.1"

echo -e "$ip:$SERVICE_PORT의 api-server를 종료합니다."
fuser -s -k -TERM $SERVICE_PORT/tcp
sleep 5

echo -e "$ip:$SERVICE_PORT에 api-server를 실행시킵니다."
java -jar -Dserver.port=${SERVICE_PORT} -DLOG_N_CRASH_APP_KEY=${LOG_N_CRASH_APP_KEY} -Dspring.profiles.active=prod ~/target/api-server-0.0.1-SNAPSHOT.jar > ~/log/api_output.log 2> ~/log/api_error.log &
sleep 10

for retry in {1..10}
do
  RESPONSE=$(curl -s http://$ip:$SERVICE_PORT/management/health)
  PORT_HEALTH=$(echo ${RESPONSE} | grep 'UP' | wc -l)
  if [ $PORT_HEALTH -eq 1 ];
  then
    break
  else
    echo -e "$ip:$SERVICE_PORT가 켜져있지 않습니다. 10초 슬립하고 다시 헬스체크를 수행합니다."
    sleep 5
  fi
done


echo -e "$ip:$TMP_PORT의 api-server를 종료합니다."
fuser -s -k -TERM $TMP_PORT/tcp
sleep 5





