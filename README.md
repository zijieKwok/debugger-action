# Safe Action Debugger

Interactive debugger for GitHub Actions with safety enhancements

## Usage

```
steps:
- name: Setup Debug Session
  uses: tete1030/debugger-action@master
```

### Encrypt sensitive information

For safety considerations, you are required to set either `TMATE_ENCRYPT_PASSWORD` or `SLACK_WEBHOOK_URL` in your environment variables. `TMATE_ENCRYPT_PASSWORD` allows you to encrypt sensitive information, or `SLACK_WEBHOOK_URL` allows sensitive information to be sent privately to your Slack client. Of course, you can use both of them.

If you have set `TMATE_ENCRYPT_PASSWORD`, in the log for the action you will see:
```bash
The following are encrypted tmate SSH and URL
To decrypt, run
    echo "ENCRYPTED_STRING" | openssl base64 -d | openssl enc -d -aes-256-cbc -k "TMATE_ENCRYPT_PASSWORD"

    SSH: U2FsdGVkX18RKoe25F+zOrjQx/TQ3yeQ2uLaYxCyShJ8EU3Ns0cTwRMtNKgXZ4Hyzje2GOBr/FUrKNt2jQyOjg== 
    Web: U2FsdGVkX18HEMUbl0xvxPUyQ8LDI6+KucuVs88eYIz+dJ5ftv0+rYxusY0kApMEkWjXZfzJUKv1NjjxquOldQ==

After connecting you should run 'touch /tmp/tmate-1577812088/keepalive' to disable the timeout.
Or the session will be KILLED in 300 seconds
To skip this step, simply connect the ssh and exit.
```
Follow the instructions to decrypt either SSH command line or Web URL of tmate. For example, if `TMATE_ENCRYPT_PASSWORD` is `my_password`, run
```bash
echo "U2FsdGVkX18RKoe25F+zOrjQx/TQ3yeQ2uLaYxCyShJ8EU3Ns0cTwRMtNKgXZ4Hyzje2GOBr/FUrKNt2jQyOjg==" | openssl base64 -d | openssl enc -d -aes-256-cbc -k "my_password"
```
You will get:
```bash
ssh yaqAx5vpGC5Ch7Mvw5u9sXxq4@nyc1.tmate.io
```

### Or, sending plain sensitive information to your Slack

> See [instructions](https://api.slack.com/messaging/webhooks) on how to get your Slack Webhook URL

If you don't want to use `TMATE_ENCRYPT_PASSWORD`, your sensitive information will only be sent in plain text to your Slack client, only if you have provided `SLACK_WEBHOOK_URL`. The log will show:

```
You have not configured TMATE_ENCRYPT_PASSWORD for encrypting sensitive information
The tmate SSH and URL are only sent to your Slack through SLACK_WEBHOOK_URL

After connecting you should run 'touch /tmp/tmate-1577812404/keepalive' to disable the timeout.
Or the session will be KILLED in 300 seconds
To skip this step, simply connect the ssh and exit.
```

### You must use either the encryption or Slack

If you haven't set `SLACK_WEBHOOK_URL` either, an error will be raised. The risk of publishing your tmate connection is huge, because **other people can retrieve your secrets through tmate**. 

### About message display and timeout

> TIPS: All above messages are displayed every 30 seconds for 30 minutes. (You can customize by setting `TIMEOUT_MIN` and `DISP_INTERVAL_SEC` env)

Simply follow the instructions and copy the (decrypted) ssh command into your terminal, or the Web URL to your browser, to create an ssh connection to the running instance. The session will close immedeatly after closing the ssh connection to the running instance.

There is a global timeout after 30 minutes (if you didn't specify other value). This will close any open ssh sessions. **To prevent the session from being terminated**, run:

```bash
# replace * with the value provided in your message
touch /tmp/tmate-*/keepalive
```

## Options

- `TIMEOUT_MIN`: timeout in minutes
- `DISP_INTERVAL_SEC`: display interval in seconds
- `SLACK_WEBHOOK_URL`: Slack Webhook URL for sending message to your slack
- `TMATE_ENCRYPT_PASSWORD`: the password used for encrypting tmate message shown in the log
- `TMATE_DOCKER_IMAGE`: if you want the debugger to be used in docker image, specify the image's name
- `TMATE_DOCKER_IMAGE_EXP`: specify the image name for saving the changes during docker image debugging

## Acknowledgments

* [tmate.io](https://tmate.io)
* Max Schmitt's [action-tmate](https://github.com/mxschmitt/action-tmate)
* Christopher Sexton's [debugger-action](https://github.com/csexton/debugger-action)

### License

The action and associated scripts and documentation in this project are released under the MIT License.
