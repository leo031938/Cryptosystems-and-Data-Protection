#!/bin/bash
# find minimal syscalls by removing from default syscalls

rm list-of-min-syscalls
while read s
do
  echo "$s  being removed from moby-default.json"
  grep -v "\"${s}\"" ./moby-default.json > tmp.json
  #docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.200 --hostname www.cyber23.test --add-host db.cyber23.test:203.0.113.201 -p 80:80 --name u2126529_csvs2023-web_c --security-opt seccomp:tmp.json u2126529/csvs2023-web_i 

  docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.200 --hostname www.cyber23.test --add-host db.cyber23.test:203.0.113.201 -p 80:80 --name u2126529_csvs2023-web_c \
--cap-drop=ALL \
--cap-add=chown \
--cap-add=net_bind_service \
--cap-add=setgid \
--cap-add=setuid \
--security-opt label:type:Web_t \
--security-opt seccomp:tmp.json u2126529/csvs2023-web_i


  # Wait for container to start
  sleep 5s
  
  # Send GET request
  Get_response=$(curl --write-out "%{http_code}" --silent --output /dev/null --max-time 5 http://localhost/index.php)
 
  # Send POST request
  value=($RANDOM%1000 +1)
  echo $value
  Post_response=$(curl --write-out "%{http_code}" --silent --output /dev/null --max-time 5 -X POST -d "fullname=$value&suggestion=$value" http://localhost/action.php)

  if [[ $Get_response -eq 200 && $Post_response -eq 302 ]]; then
    echo "$s is running properly, do nothing"
	
  else 
    echo "$s is not success, adding to list-of-min-syscalls"
    echo $s >> list-of-min-syscalls

  fi

  # kill docker
  docker kill u2126529_csvs2023-web_c

done < ./moby-syscalls



