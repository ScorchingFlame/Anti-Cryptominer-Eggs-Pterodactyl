#!/bin/bash

#
# Copyright (c) 2022 Ritheesh
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

echo "░█████╗░██████╗░███████╗███████╗██████╗░███████╗██████╗░██╗░░██╗░█████╗░░██████╗████████╗"
echo "██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝██╔══██╗██║░░██║██╔══██╗██╔════╝╚══██╔══╝"
echo "██║░░╚═╝██████╔╝█████╗░░█████╗░░██████╔╝█████╗░░██████╔╝███████║██║░░██║╚█████╗░░░░██║░░░"
echo "██║░░██╗██╔══██╗██╔══╝░░██╔══╝░░██╔═══╝░██╔══╝░░██╔══██╗██╔══██║██║░░██║░╚═══██╗░░░██║░░░"
echo "╚█████╔╝██║░░██║███████╗███████╗██║░░░░░███████╗██║░░██║██║░░██║╚█████╔╝██████╔╝░░░██║░░░"
echo "░╚════╝░╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░░░░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═════╝░░░░╚═╝░░░"
echo ""
PROJECT=paper

apt update
apt install -y curl jq

if [ -n "${DL_PATH}" ]; then
	echo -e "Using supplied download url: ${DL_PATH}"
	DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's\/{{\/${\/g' -e 's\/}}\/}\/g')`
else
	VER_EXISTS=`curl -s https:\/\/papermc.io\/api\/v2\/projects\/${PROJECT} | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep true`
	LATEST_VERSION=`curl -s https:\/\/papermc.io\/api\/v2\/projects\/${PROJECT} | jq -r '.versions' | jq -r '.[-1]'`

	if [ "${VER_EXISTS}" == "true" ]; then
		echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
	else
		echo -e "Using the latest ${PROJECT} version"
		MINECRAFT_VERSION=${LATEST_VERSION}
	fi
	
	BUILD_EXISTS=`curl -s https:\/\/papermc.io\/api\/v2\/projects\/${PROJECT}\/versions\/${MINECRAFT_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds[] | tostring | contains($BUILD)' | grep true`
	LATEST_BUILD=`curl -s https:\/\/papermc.io\/api\/v2\/projects\/${PROJECT}\/versions\/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]'`
	
	if [ "${BUILD_EXISTS}" == "true" ]; then
		echo -e "Build is valid for version ${MINECRAFT_VERSION}. Using build ${BUILD_NUMBER}"
	else
		echo -e "Using the latest ${PROJECT} build for version ${MINECRAFT_VERSION}"
		BUILD_NUMBER=${LATEST_BUILD}
	fi
	
	JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar
	
	echo "Version being downloaded"
	echo -e "MC Version: ${MINECRAFT_VERSION}"
	echo -e "Build: ${BUILD_NUMBER}"
	echo -e "JAR Name of Build: ${JAR_NAME}"
	DOWNLOAD_URL=https:\/\/papermc.io\/api\/v2\/projects\/${PROJECT}\/versions\/${MINECRAFT_VERSION}\/builds\/${BUILD_NUMBER}\/downloads\/${JAR_NAME}
fi

cd \/mnt\/server

echo -e "Running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [ -f ${SERVER_JARFILE} ]; then
	mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

if [ ! -f server.properties ]; then
    echo -e "Downloading MC server.properties"
    curl -o server.properties https:\/\/raw.githubusercontent.com\/parkervcp\/eggs\/master\/game_eggs\/minecraft\/java\/server.properties
fi

clear

# Switch to the container's working directory
cd /home/container || exit 1

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}
