# Action Debugger

Interactive debugger for GitHub Actions

## Usage

```
steps:
- name: Setup Debug Session
  uses: tete1030/debugger-action@my
```

In the log for the action you will see:

```
To connect to this session copy-n-paste the following into a terminal or browser:

ssh Y26QeagDtsPXp2mT6me5cnMRd@nyc1.tmate.io

https://tmate.io/t/Y26QeagDtsPXp2mT6me5cnMRd
```
> TIPS: This message is displayed every 30 seconds for 30 minutes. (You can customize by setting TIMEOUT_MIN and DISP_INTERVAL_SEC env)

Simply follow the instructions and copy the ssh command into your terminal to create an ssh connection the running instance. The session will close immedeatly after closing the ssh connection to the running instance.

There is a global timeout after 30 minutes (if you didn't specify other value). This will close any open ssh sessions. To prevent the session from being terminated run:

```
touch /tmp/tmate-*/keepalive
```

## Options

- `TIMEOUT_MIN`: timeout in minutes
- `DISP_INTERVAL_SEC`: display interval in seconds
- `SLACK_WEBHOOK_URL`: Slack Webhook URL for sending message to your slack
- `TMATE_DOCKER_IMAGE`: if you want the debugger to be used in docker image, specify the image's name
- `TMATE_DOCKER_IMAGE_EXP`: specify the image name for saving the changes during docker image debugging

## Acknowledgments

* [tmate.io](https://tmate.io)
* Max Schmitt's [action-tmate](https://github.com/mxschmitt/action-tmate)
* Christopher Sexton's [debugger-action](https://github.com/csexton/debugger-action)

### License

The action and associated scripts and documentation in this project are released under the MIT License.
