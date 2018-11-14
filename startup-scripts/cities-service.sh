#!/bin/bash
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
DIR=spring-boot-cities-service
if [ ! -d "$DIR" ]; then
  git clone https://github.com/Sufyaan-Kazi/spring-boot-cities-service.git
fi
cd $DIR
nohup ./gradlew bootRun
