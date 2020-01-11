# Safe Action Debugger

Interactive debugger for GitHub Actions. The connection information can be encrypted or sent privately to you. It also supports attaching docker image/container.

## Usage

Standard:
```yml
steps:
- name: Setup Debug Session
  env:
    TMATE_ENCRYPT_PASSWORD: ${{secrets.TMATE_ENCRYPT_PASSWORD}}
    SLACK_WEBHOOK_URL: ${{secrets.SLACK_WEBHOOK_URL}}
  uses: tete1030/safe-debugger-action@master
```

Attach to docker container:
```yml
steps:
- name: Setup Debug Session
  env:
    TMATE_DOCKER_CONTAINER: IMAGE_TAG
    TMATE_ENCRYPT_PASSWORD: ${{secrets.TMATE_ENCRYPT_PASSWORD}}
    SLACK_WEBHOOK_URL: ${{secrets.SLACK_WEBHOOK_URL}}
  uses: tete1030/safe-debugger-action@master
```

Attach to docker image:
```yml
steps:
- name: Setup Debug Session
  env:
    TMATE_DOCKER_IMAGE: IMAGE_TAG
    TMATE_DOCKER_IMAGE_EXP: IMAGE_TAG
    TMATE_ENCRYPT_PASSWORD: ${{secrets.TMATE_ENCRYPT_PASSWORD}}
    SLACK_WEBHOOK_URL: ${{secrets.SLACK_WEBHOOK_URL}}
  uses: tete1030/safe-debugger-action@master
```

For safety considerations, you are required to set either of the two envs:
* `TMATE_ENCRYPT_PASSWORD`, this allows you to encrypt sensitive information.
* `SLACK_WEBHOOK_URL`, send sensitive information privately to your Slack client.
* Of course, you can use both of them.

### Encrypt sensitive information

If you have set `TMATE_ENCRYPT_PASSWORD`, in the log you will see:

![preview](https://github.com/tete1030/safe-debugger-action/raw/gh-pages/docs/imgs/preview.png)

Since in Github Actions, log messages are not shown completely before the step finishes, the message is printed every 30 seconds. **If you do not see any message in the debugger step**, wait for 30~60 seconds.

Follow the instructions to decrypt either SSH command line or Web URL of the debugger. The following screenshot shows the webpage built for decrypting your connection information.

![decryptor](https://github.com/tete1030/safe-debugger-action/raw/gh-pages/docs/imgs/decryptor.png)


### Or, sending plain sensitive information to Slack

> See [instructions](https://api.slack.com/messaging/webhooks) on how to get your Slack Webhook URL

If you have provided `SLACK_WEBHOOK_URL`, you will receive a message that contains plain connection info

![slack](https://github.com/tete1030/safe-debugger-action/raw/gh-pages/docs/imgs/slack.png)

### Session timeout and message display interval

There is a global timeout after 30 minutes (if you didn't specify other value for `TIMEOUT_MIN`). After you connect to the session, the timeout will be automatically disabled.

The connection info are displayed every 30 seconds. You can customize by setting `DISP_INTERVAL_SEC` env.

### Attach to docker

> The debugger action just attaches to docker image/container, it does not install anything inside. After you quit the docker image, the changes you made will be saved to the original image or specified one.

You can make the debugger attach to specified docker image/container by setting `TMATE_DOCKER_IMAGE` or `TMATE_DOCKER_CONTAINER`. It is easy to switch between Github Actions runner and docker image/container. 

![docker](https://github.com/tete1030/safe-debugger-action/raw/gh-pages/docs/imgs/docker.png)

## Environment variables

- `TIMEOUT_MIN`: timeout in minutes
- `DISP_INTERVAL_SEC`: message display interval in seconds
- `SLACK_WEBHOOK_URL`: Slack Webhook URL for sending message to your slack
- `TMATE_ENCRYPT_PASSWORD`: the password used for encrypting tmate message shown in the log
- `TMATE_DOCKER_CONTAINER`: the docker container name
- `TMATE_DOCKER_IMAGE`: the docker image tag
- `TMATE_DOCKER_IMAGE_EXP`: the docker image tag for saving changes you made in debugger. (defaults to `TMATE_DOCKER_IMAGE`)
- `TMATE_TERM`: specify the `TERM` environment variable. (defaults to `screen-256color`)

## Acknowledgments

* P3TERX's [debugger-action](https://github.com/P3TERX/debugger-action)
* [tmate.io](https://tmate.io)
* Max Schmitt's [action-tmate](https://github.com/mxschmitt/action-tmate)
* Christopher Sexton's [debugger-action](https://github.com/csexton/debugger-action)

### License

The action and associated scripts and documentation in this project are released under the MIT License.
