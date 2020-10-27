#!/bin/bash
#clear
echo "Starting Selenium Hub on Docker"

VIDEO_NAME="$3"
BUILD_FOLDER="$2"
docker run --rm  \
--net=host  -d \
-e NOVNC=true \
-e VIDEO=true \
-e VIDEO_FILE_NAME=${VIDEO_NAME}  \
-e VIDEO_FILE_EXTENSION="mkv" \
-e SCREEN_WIDTH=1920 \
-e SCREEN_HEIGHT=1080 \
-v "${BUILD_FOLDER}"/EVIDENCIAS/"${VIDEO_NAME}":/home/seluser/videos \
-v /dev/shm:/dev/shm \
-e PICK_ALL_RANDOM_PORTS=true \
--privileged  \
elgalu/selenium

id=$(docker ps -lq)
echo "Selenium Hub ID: ${id}"

echo "Waiting - Hub port [=   ]"
sleep 3
echo "Waiting - Hub port [==  ]"
sleep 3
echo "Waiting - Hub port [=== ]"
sleep 3
echo "Waiting - Hub port [====]"
sleep 1
echo "(Completed)"
sleep 1
rep=$(docker exec ${id} cat /var/log/cont/selenium-hub-stderr.log | grep "Nodes should register to" | cut -d':' -f5)
port_hub=$(echo $rep | cut -d'/' -f 1)
if [ -z $port_hub ]
then
    clear
    echo "The port was not found =("
    echo "Stopping docker Container"
    docker rm -f ${id}
    exit
else
  clear
  echo "---------------------------- PORT SCANNED ---------------------------------"
  echo "Success! The available PORT of the Hub is: ${port_hub}"
  echo "Starting the automation robot... =D"

echo "---------------------------- SCRIPT RUNNING ---------------------------------"
echo $1
echo "---------------------------- SCRIPT RUNNING ---------------------------------"
script=$1

docker run --net=host  --rm -i  --privileged  \
-v "${BUILD_FOLDER}":/opt/automation/suits \
-v "${BUILD_FOLDER}"/EVIDENCIAS/"${VIDEO_NAME}"/log:/opt/automation/results \
robot-run /bin/bash -c  "robot -v SELENIUM_IP:'127.0.0.1' -v SELENIUM_PORT:${port_hub} ${script}"

echo "---------------------------- STOPPING VIDEO ---------------------------------"
docker exec ${id} stop-video

echo "---------------------------- STOPPING CONTAINER ---------------------------------"
docker stop  ${id}

echo "---------------------------- STARTING VIDEO CONVERTING TO MP4 ---------------------------------"

dirVideo="${BUILD_FOLDER}"/EVIDENCIAS/"${VIDEO_NAME}"

###apt-get install ffmpeg
ffmpeg -i $dirVideo/${VIDEO_NAME}.mkv -codec copy $dirVideo/${VIDEO_NAME}.mp4

rm $dirVideo/${VIDEO_NAME}.mkv



echo "---------------------------- FINISH AUTOMAITON ---------------------------------"
echo "---------------------------- FINISH AUTOMATION ---------------------------------"
echo "---------------------------- FINISH AUTOMATION ---------------------------------"

fi
