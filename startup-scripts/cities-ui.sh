#!/bin/bash
# “Copyright 2018 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreements with Google.”  
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# “Copyright 2018 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.
#  Your use of it is subject to your agreements with Google.”
#

sudo apt-get update
sudo apt-get -y install default-jdk
sudo apt-get -y install git-core
DIR=spring-boot-cities-ui
if [ ! -d "$DIR" ]; then
  git clone https://github.com/Sufyaan-Kazi/spring-boot-cities-ui.git
fi
cd $DIR
FWD_IP=`gcloud compute forwarding-rules list | grep cities-service | xargs | cut -d ' ' -f 3` 
export SPRING_CITIES_WS_URL=http://${FWD_IP}:8080/cities
echo "****************** Connecting to cities-service: ${SPRING_CITIES_WS_URL} *********************"
sleep 5
nohup ./gradlew bootRun
