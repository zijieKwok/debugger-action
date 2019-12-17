#!/bin/bash

set -e

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
tmate -S /tmp/tmate.sock new-session -d
tmate -S /tmp/tmate.sock wait tmate-ready

if [[ ! -z "$SLACK_WEBHOOK_URL" ]]; then
  MSG=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}')
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"\`$MSG\`\"}" $SLACK_WEBHOOK_URL
fi

echo ________________________________________________________________________________
echo To connect to this session copy-n-paste the following into a terminal or browser:

# Wait for connection to close or timeout
timeout=$(( ${TIMEOUT_MIN:=30}*60 ))
display_int=${DISP_INTERVAL_SEC:=30}
timecounter=0

while [ -S /tmp/tmate.sock ]; do
  if [ ! -f /tmp/keepalive ]; then
    if (( timecounter > timeout )); then
      echo Waiting on tmate connection timed out!
      if [ "x$FAIL_QUIT" = "x1" -o "x$FAIL_QUIT" = "xtrue" ]; then
        sudo init 0
      else
        exit 1
      fi
    fi
  fi

  if (( timecounter % display_int == 0 )); then
    tmate -S /tmp/tmate.sock display -p 'SSH: #{tmate_ssh}'
    tmate -S /tmp/tmate.sock display -p 'WEB: #{tmate_web}'
    [ ! -f /tmp/keepalive ] && echo -e "After connecting you can run 'touch /tmp/keepalive' to disable the timeout"
  fi

  sleep 1
  timecounter=$(($timecounter+1))
done
