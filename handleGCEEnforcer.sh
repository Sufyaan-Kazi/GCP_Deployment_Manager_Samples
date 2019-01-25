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
. vars.properties
. dmFunctions.sh

echo_mesg "Deleting previos firewall rule deployments"
deleteDeploymentAsync cities-service-lb-fw &
deleteDeploymentAsync cities-ui-lb-fw &
deleteDeploymentAsync cities-ui-fw &
wait

echo_mesg "Creating Firewall Rules"
createFirewall-LBToTag cities-service $NETWORK $BE_PORT $BE_TAG
createFirewall-LBToTag cities-ui $NETWORK $FE_PORT $FE_TAG
createFirewall-TagToTag cities-ui $NETWORK $BE_PORT $FE_TAG $BE_TAG
waitForHealthyBackend cities-ui
