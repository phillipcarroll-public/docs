# Core Utils - nohup

`nohup` == No Hangup.

This is the `fox3` of utilities. This allows you to run a command/script/thing and let it continue to run in the background even if the user logs out or is dropped/disconnected from the session.

`nohup` simply makes the command immune to the hang-up signal associated to the processes for a session.

This is commonly used with `&` to run the command in the background.

Example: `nohup ./some_script.sh &`

`nohup` will redirect output for stdout and stderr to nohup.out in the working dir. You can specify a custom log for the output: `nohop ./some_script > some_log 2>&1 &`

This is useful for long downloads, long scripts etc...
