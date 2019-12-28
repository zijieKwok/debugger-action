#!/bin/bash

set -eo pipefail
set -x

# For mount docker volume, do not directly use '/tmp' as the dir
TMATE_TERM=${TMATE_TERM:-screen-256color}
TIMESTAMP="$(date +%s)"
MILLISEC="$(date +%3N)"
TIMESTAMP_MILLISEC="${TIMESTAMP}${MILLISEC}"
TMATE_SOCK_FILE="/tmp/tmate-${TIMESTAMP_MILLISEC}.sock"
KEEPALIVE_DIR="/tmp/tmate-${TIMESTAMP}"
KEEPALIVE_FILE="${KEEPALIVE_DIR}/keepalive"
TMATE_SESSION_NAME="tmate-${TIMESTAMP_MILLISEC}"

cleanup() {
  if [ ! -z "${container_id}" ]; then
    echo "Current docker container will be saved to your image: ${TMATE_DOCKER_IMAGE_EXP}"
    docker stop "${container_id}" > /dev/null
    docker commit --message "Commit from debugger-action" "${container_id}" "${TMATE_DOCKER_IMAGE_EXP}"
    docker rm "${container_id}" > /dev/null
  fi
  tmate kill-session -t ${TMATE_SESSION_NAME}
  sed -i '/alias attach_docker/d' ~/.bashrc || true
  sudo rm -rf "${KEEPALIVE_DIR}"
  sudo rm -f "${TMATE_SOCK_FILE}"
}

if [[ ! -z "$SKIP_DEBUGGER" ]]; then
  echo "Skipping debugger because SKIP_DEBUGGER enviroment variable is set"
  exit
fi

# Install tmate on macOS or Ubuntu
echo Setting up tmate...
if [ -x "$(command -v brew)" ]; then
  brew install tmate > /tmp/brew.log
fi
if [ -x "$(command -v apt-get)" ]; then
  curl -fsSL git.io/tmate.sh | bash
fi

# Generate ssh key if needed
[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

# Run deamonized tmate
echo Running tmate...

sudo mkdir "${KEEPALIVE_DIR}" || true
sudo chmod 777 "${KEEPALIVE_DIR}"
sudo rm "${KEEPALIVE_FILE}" || true
container_id=''
if [ ! -z "${TMATE_DOCKER_IMAGE}" ]; then
  if [ -z "${TMATE_DOCKER_IMAGE_EXP}" ]; then
    TMATE_DOCKER_IMAGE_EXP="${TMATE_DOCKER_IMAGE}"
  fi
  echo Creating docker container for running tmate
  container_id=$(docker create -it -v "${KEEPALIVE_DIR}:${KEEPALIVE_DIR}" "${TMATE_DOCKER_IMAGE}")
  docker start "${container_id}"
  docker exec -it -u root "${container_id}" rm "${KEEPALIVE_FILE}" || true
  DK_SHELL="docker exec -it ${container_id} /bin/bash -il"
  DOCKER_MESSAGE_CMD='printf "This window is running in Docker image.\nTo attach to Github Actions runner, exit current shell\nor create a new tmate window by \"Ctrl-b, c\"\n(shortcut same to tmux, only available when connecting through ssh)\n"'
  FIRSTWIN_MESSAGE_CMD='printf "This window is now running in GitHub Actions runner.\nTo attach to your Docker image again, use \"attach_docker\" command\n"'
  SECWIN_MESSAGE_CMD='printf "The first window of tmate has already been attached to your Docker image.\nThis window is running in GitHub Actions runner.\nTo attach to your Docker image again, use \"attach_docker\" command\n"'
  echo "unalias attach_docker 2>/dev/null || true ; alias attach_docker='${DK_SHELL}'" >> ~/.bashrc
  TERM="${TMATE_TERM}" tmate -S ${TMATE_SOCK_FILE} new-session -s ${TMATE_SESSION_NAME} -d "/bin/sh -c '${DOCKER_MESSAGE_CMD} ; ${DK_SHELL} ; ${FIRSTWIN_MESSAGE_CMD} ; /bin/bash -li'" \; set-option default-command "/bin/sh -c '${SECWIN_MESSAGE_CMD} ; /bin/bash -li'" \; set-option default-terminal "${TMATE_TERM}"
else
  echo "unalias attach_docker 2>/dev/null || true" >> ~/.bashrc
  TERM="${TMATE_TERM}" tmate -S ${TMATE_SOCK_FILE} new-session -s ${TMATE_SESSION_NAME} -d \; set-option default-terminal "${TMATE_TERM}"
fi

tmate -S ${TMATE_SOCK_FILE} wait tmate-ready

timeout=$(( ${TIMEOUT_MIN:=30}*60 ))

SSH_LINE="$(tmate -S ${TMATE_SOCK_FILE} display -p 'SSH: #{tmate_ssh}')"
WEB_LINE="$(tmate -S ${TMATE_SOCK_FILE} display -p 'WEB: #{tmate_web}')"
KEEPALIVE_MESSAGE="After connecting you should run \`touch ${KEEPALIVE_FILE}\` to disable the timeout. Or the session will be **KILLED** in ${timeout} seconds."

if [[ ! -z "$SLACK_WEBHOOK_URL" ]]; then
  MSG="${SSH_LINE}\n${WEB_LINE}"
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"\`\`\`\n$MSG\n\`\`\`\n${KEEPALIVE_MESSAGE}\"}" "$SLACK_WEBHOOK_URL"
fi

echo ________________________________________________________________________________
echo To connect to this session copy-n-paste the following into a terminal or browser:

# Wait for connection to close or timeout
display_int=${DISP_INTERVAL_SEC:=30}
timecounter=0

while [ -S ${TMATE_SOCK_FILE} ]; do
  if [ ! -f "${KEEPALIVE_FILE}" ]; then
    if (( timecounter > timeout )); then
      echo Waiting on tmate connection timed out!
      cleanup

      if [ "x$TIMEOUT_FAIL" = "x1" -o "x$TIMEOUT_FAIL" = "xtrue" ]; then
        exit 1
      else
        exit 0
      fi
    fi
  fi

  if (( timecounter % display_int == 0 )); then
    echo "${SSH_LINE}"
    echo "${WEB_LINE}"
    [ ! -f "${KEEPALIVE_FILE}" ] && printf "After connecting you should run \`touch ${KEEPALIVE_FILE}\` to disable the timeout.\nOr the session will be KILLED in $(( $timeout-$timecounter )) seconds\n"
  fi

  sleep 1
  timecounter=$(($timecounter+1))
done

cleanup
