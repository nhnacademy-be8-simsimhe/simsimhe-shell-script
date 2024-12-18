ports=("3000" "3001")
ip="127.0.0.1"


for port in "${ports[@]}";
do
  echo -e "http://$ip:$port/management/health_check"
  RESPONSE=$(curl -s http://$ip:$port/management/health)
  IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)
  if [ $IS_ACTIVE -eq 1 ];
  then
    echo -e "nginx 설정파일에서 $port를 제거합니다."
    echo -e "sed -i /localhost:$port/d /etc/nginx/nginx.conf"
    sudo sed -i "/localhost:$port/d" /etc/nginx/nginx.conf

    sudo nginx -t
    echo "nginx를 reload합니다."
    sudo nginx -s reload
    sleep 5

    fuser -s -k -TERM $port/tcp
    sleep 5

    echo -e "jar파일을 $port포트에 실행합니다."
    nohup java -jar -Dserver.port=${port} -DLOG_N_CRASH_APP_KEY=${LOG_N_CRASH_APP_KEY} -Dspring.profiles.active=prod ~/target/front-server-0.0.1-SNAPSHOT.jar &
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
      echo -e "$ip:$port에 정상적으로 spring boot가 실행 중입니다."
    else
      echo -e "$ip:$port에 정상적으로 spring boot가 실행 중이 아닙니다."
      exit 0
    fi

    echo -e "nginx 설정파일에 $ip:$port을 추가합니다."
    sudo sed -i "/upstream loadbalancer {/ a \    server localhost:$port;" /etc/nginx/nginx.conf

    sudo nginx -t
    echo "nginx를 reload합니다."
    sudo nginx -s reload
    sleep 5
  else
    echo -e "$port포트에 spring boot가 실행중이 아닙니다."
    exit 0
  fi
done



