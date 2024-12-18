source ~/variables

SERVICE_PORT="8020"
TMP_PORT="8021"
ip="127.0.0.1"

RESPONSE=$(curl -s http://$ip:$SERVICE_PORT/management/health)
IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)


if [ $IS_ACTIVE -eq 1 ];
then
  echo -e "$SERVICE_PORT에 auth-server가 실행 중입니다."
else
  echo -e "$SERVICE_PORT에 auth-server가 실행 중이 아닙니다."
  echo -e "$SERVICE_PORT에 auth-server를 실행시킵니다."
  java -jar -Dserver.port=${SERVICE_PORT} -DLOG_N_CRASH_APP_KEY=${LOG_N_CRASH_APP_KEY}  ~/target/account-server-0.0.1-SNAPSHOT.jar > ~/log/auth_output.log 2> ~/log/auth_error.log &
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
      sleep 10
    fi
  done
fi

RESPONSE=$(curl -s http://$ip:$SERVICE_PORT/management/health)
PORT_HEALTH=$(echo ${RESPONSE} | grep 'UP' | wc -l)

if [ $PORT_HEALTH -eq 1 ];
then
  echo -e "$ip:$SERVICE_PORT에 정상적으로 auth-server가 실행 중입니다."
else
  echo -e "$ip:$SERVICE_PORT에 정상적으로 auth-server가 실행 중이 아닙니다."
  exit 0
fi

PID=$(lsof -t -i:$TMP_PORT)
if [ -n "$PID" ]; # $PID는 비어있지 않다는 조건문
then
  echo -e "$ip:$TMP_PORT에 실행 중인 프로세스를 종료합니다."
  kill -15 $PID
  sleep 10
fi

echo -e "$ip:$TMP_PORT에 auth-server를 실행합니다."
java -jar -Dserver.port=${TMP_PORT} -DLOG_N_CRASH_APP_KEY=${LOG_N_CRASH_APP_KEY}  ~/target/account-server-0.0.1-SNAPSHOT.jar > /dev/null 2> ~/log/auth_error.log &
sleep 10

for retry in {1..10}
do
  RESPONSE=$(curl -s http://$ip:$TMP_PORT/management/health)
  PORT_HEALTH=$(echo ${RESPONSE} | grep 'UP' | wc -l)
  if [ $PORT_HEALTH -eq 1 ];
  then
    break
  else
    echo -e "$ip:$TMP_PORT가 켜져있지 않습니다. 10초 슬립하고 다시 헬스체크를 수행합니다."
    sleep 10
  fi
done

RESPONSE=$(curl -s http://$ip:$TMP_PORT/management/health)
PORT_HEALTH=$(echo ${RESPONSE} | grep 'UP' | wc -l)
if [ $PORT_HEALTH -eq 1 ];
    then
      echo -e "$ip:$TMP_PORT에 정상적으로 auth-server가 실행 중입니다."
    else
      echo -e "$ip:$TMP_PORT에 정상적으로 auth-server가 실행 중이 아닙니다."
      exit 0
fi
