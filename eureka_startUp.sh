source ~/variables
port="8761"
ip="127.0.0.1"

RESPONSE=$(curl -s http://$ip:$port/management/health)
IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)
if [ $IS_ACTIVE -eq 1 ];
then
  fuser -s -k -TERM $port/tcp
  sleep 5
fi

echo -e "$ip:$port에 spring cloud eureka server를 실행합니다."
java -jar -Dserver.port=${port} -DLOG_N_CRASH_APP_KEY=${LOG_N_CRASH_APP_KEY}  ~/target/eureka-0.0.1-SNAPSHOT.jar > /dev/null 2> ~/log/eureka_error.log &
sleep 5

for retry in {1..10}
do
  RESPONSE=$(curl -s http://$ip:$port/management/health)
  PORT_HEALTH=$(echo ${RESPONSE} | grep 'UP' | wc -l)
  if [ $PORT_HEALTH -eq 1 ];
  then
    break
  else
    echo -e "$ip:$port가 켜져있지 않습니다. 10초 슬립하고 다시 헬스체크를 수행합니다."
    sleep 10
  fi
done

if [ $PORT_HEALTH -eq 1 ];
then
  echo -e "$ip:$port에 정상적으로 spring cloud eureka server가 실행 중입니다."
else
  echo -e "$ip:$port에 정상적으로 spring cloud eureka server가 실행 중이 아닙니다."
  exit 0
fi

