docker exec -it /bin/bash


DB:
sudo make -f /usr/share/selinux/devel/Makefile DB.pp

sudo semodule -i DB.pp

sudo semodule -l | grep DB

docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.201 --hostname db.cyber23.test -e MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" -e MYSQL_DATABASE="csvs23db" --name u2126529_csvs2023-db_c \
--security-opt label:type:DB_t \
--security-opt seccomp:list-of-min-syscalls-db.json \
--cap-drop=ALL \
-v mysql:/var/lib/mysql \
u2126529_csvs2023-db_i



docker exec -i u2126529_csvs2023-db_c mysql -uroot -pCorrectHorseBatteryStaple < sqlconfig/csvs23db.sql




all&slim:
build --target u2126529_csvs2023-db_i:latest --env "MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" --env "MYSQL_DATABASE="csvs23db" --http-probe-off --tag u2126529_csvs2023-db_i.slim

docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.201 --hostname db.cyber23.test -e MYSQL_ROOT_PASSWORD="CorrectHorseBatteryStaple" -e MYSQL_DATABASE="csvs23db" --name u2126529_csvs2023-db_c \
--security-opt label:type:DB_t \
--security-opt seccomp:list-of-min-syscalls-db.json \
--cap-drop=ALL \
-v mysql:/var/lib/mysql \
u2126529_csvs2023-db_i.slim







Web:
sudo make -f /usr/share/selinux/devel/Makefile Web.pp

sudo semodule -i Web.pp

sudo semodule -l | grep Web

docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.200 --hostname www.cyber23.test --add-host db.cyber23.test:203.0.113.201 -p 80:80 --name u2126529_csvs2023-web_c \
--security-opt label:type:Web_t \
u2126529/csvs2023-web_i


--cap-drop=ALL \
--cap-add=chown \
--cap-add=net_bind_service \
--cap-add=setgid \
--cap-add=setuid \



SE&seccomp&cap:
docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.200 --hostname www.cyber23.test --add-host db.cyber23.test:203.0.113.201 -p 80:80 --name u2126529_csvs2023-web_c \
--security-opt label:type:Web_t \
--security-opt seccomp:list-of-min-syscalls-Web.json \
--cap-drop=ALL \
--cap-add=chown \
--cap-add=net_bind_service \
--cap-add=setgid \
--cap-add=setuid \
--cap-add=dac_override \
u2126529/csvs2023-web_i.slim



all&slim:

build --target u2126529/csvs2023-web_i:0.2 --include-path '/var/lib/nginx/tmp/client_body' --include-path '/usr/share/nginx/html'  --tag u2126529/csvs2023-web_i.slim2

docker run -d --rm --net u2126529/csvs2023_n --ip 203.0.113.200 --hostname www.cyber23.test --add-host db.cyber23.test:203.0.113.201 -p 80:80 --name u2126529_csvs2023-web_c \
--security-opt label:type:Web_t \
--security-opt seccomp:list-of-min-syscalls-Web.json \
--cap-drop=ALL \
--cap-add=chown \
--cap-add=net_bind_service \
--cap-add=setgid \
--cap-add=setuid \
--cap-add=dac_override \
u2126529/csvs2023-web_i.slim2









docker export u2126529_csvs2023-web_c | tar -x -C ./
diff -r diff/ diff2/ > ./re.txt


