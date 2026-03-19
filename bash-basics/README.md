# Bash Basics

### Shebang

Most bash scripts should start with: `#!/bin/bash`

`#!` the shebang tells the OS what interpreter to execute the script with.

You can set this to other shells like zsh or fish.

`#!/bin/bash`

`#!/usr/bin/zsh`

`#!/usr/bin/fish`

### Execute Commands

This is very simple, write your commands in the bash script the same way you would execute them in the bash shell/cli.

```bash
#!/bin/bash

echo "Hello"
echo "World"
ls -al
```

In most cases you do not need to add `&& \` to string multiple lines together. In bash each line is executed independently and serially top to bottom. However if you wanted to break up a long command into multiple lines it will be executed the same way as in the bash shell/cli.

```bash
#!/bin/bash

echo "This is \
a multi line \
echo command"
ls -al
ping \
8.8.8.8
```

### Variables

Strings, Integers, and Arrays

```bash
#!/bin/bash

text_message="Hello, world!"
home_download="/home/user/Downloads"
folders=("/home/user/Documents" "/var/log" "/tmp")
ping_count=3
ip_address="8.8.8.8"

echo "$text_message"

ls -al "$home_download"

for folder in "${folders[@]}"; do
    ls -al "$folder"
done

ping -c $ping_count "$ip_address"
```

### Loops

For loop, the element "thing" in a set of things:

```bash
for thing in thing1 thing2 thing3; do
    echo "I like $thing"
done
```

Loop a number of times:

```bash
count=0

while [ $count -lt 5 ]; do
    echo "Count is: $count"
    count=$((count + 1))
done
```

Using the Array example from up above, when you iterate over each element in the array. This is nearly identical to the first loop example:

```bash
folders=("/home/user/Documents" "/var/log" "/tmp")

for folder in "${folders[@]}"; do
    ls -al "$folder"
done
```

Similar to a while loop we can do an until loop. Keep looping until condition:

```bash
count=0

until (( count == 5 )); do
    echo "Count: $count"
    count=$((count + 1))
done
```

You can also leverage `if` for indirect loops.

### Logic Control

**if, then, case, &&, ||**

### if and then

Simple if (true if command succeeds)

```bash
# if /tmp is greater than null
if ls /tmp >/dev/null 2>&1; then
    echo "tmp directory exists"
fi
```

If-Else

```bash
# if‑else with string comparison
read -p "Enter Y or N: " ans

if [[ $ans == "Y" ]]; then
    echo "You chose Yes"
else
    echo "You chose No"
fi
```

If-Elif-Else

$1 is just the first positional argument passed to the script: `myscript.sh somearghere`

```bash
num=$1

if (( num < 0 )); then
    echo "Negative"
elif (( num == 0 )); then
    echo "Zero"
else
    echo "Positive"
fi
```

### case

Simple case on a variable

```bash
read -p "Pick a fruit (apple/banana/cherry): " fruit

case $fruit in
    apple)  echo "You chose Apple." ;;
    banana) echo "You chose Banana." ;;
    cherry) echo "You chose Cherry." ;;
    *)      echo "Unknown fruit." ;;
esac
```

Multiple patterns per branch

```bash
action=$1

case $action in
    start|run|go)   echo "Starting service..." ;;
    stop|end|quit)  echo "Stopping service..." ;;
    restart)        echo "Restarting service..." ;;
    *)              echo "Invalid action: $action" ;;
esac
```

### && and ||

Same usage as you typically would to string commands together with &&:

```bash
sudo apt update -y && sudo apt upgrade -y
```

|| is or, if the first command is not valid the second command will run. 

```bash
if command1 && command2 || command3; then
echo "Either both command1&2 succeeded, or command3 succeeded"
fi
```

### Functions

Remember $1 is the value passed to the function/script. In this example we call next_stage and pass 2.

```bash
next_stage() {
    echo "$1" > "$STATE_FILE"
    echo "Rebooting to proceed to stage $1..."
    reboot
}

next_stage 2
```

Passing several args, use $@ to echo all passed args.

```bash
show_info() {
echo "First  : $1"
echo "Second : $2"
echo "Third  : $3"
echo "All args: $@"
}

show_info "thing1" "thing2" "thing3"
```

### Handling Prompts

Sometimes a program will force you to select/type something in a prompt, we need to be able to handle that. Lets assume `apt update` without the `-y` tag. The `yes` command is available:

```bash
#!/bin/bash

yes | apt upgrade
```

We can also pass a "Y"

```bash
#!/bin/bash

yes "Y" | apt upgrade
```

We could provide similar with `expect` which looks at the text in the prompt to render an answer:

```bash
#!/bin/bash

yes | sudo apt install expect

expect -c '
spawn sudo apt upgrade
expect {
    "password for" { send "your_sudo_password\r"; exp_continue }
    "Do you want to continue? \[Y/n\]" { send "Y\r" }
}
expect eof
'
```

### Handling Input Args

We can mimic a help menu by giving a case for specific args and what to pass (help) when no args are passed. This will also error out if more than one option is selected:

```bash
#!/bin/bash

# Check the number of arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 [option]"
    echo "Available options:"
    echo "  option1 - Perform action 1"
    echo "  option2 - Perform action 2"
    echo "  option3 - Perform action 3"
    exit 0
elif [ $# -gt 1 ]; then
    echo "Error: Too many arguments. Please provide only one option."
    exit 1
fi

# Process the single argument
case "$1" in
    option1)
        echo "Executing option1: Action 1 performed!"
        # Add your code for option1 here
        ;;
    option2)
        echo "Executing option2: Action 2 performed!"
        # Add your code for option2 here
        ;;
    option3)
        echo "Executing option3: Action 3 performed!"
        # Add your code for option3 here
        ;;
    *)
        echo "Error: Invalid option '$1'."
        echo "Run without arguments for usage."
        exit 1
        ;;
esac
```

### Create Menus and Selections

Basic menu scructure with a return to main menu:

```bash
#!/bin/bash

# Simple menu script with 3 options that return to main menu

while true; do
    echo "Main Menu:"
    echo "1) Option 1"
    echo "2) Option 2"
    echo "3) Option 3"
    echo "4) Exit"
    echo -n "Enter your choice: "
    read choice

    case $choice in
        1)
            echo "You selected Option 1."
            # Add your code for Option 1 here
            echo "Returning to main menu..."
            ;;
        2)
            echo "You selected Option 2."
            # Add your code for Option 2 here
            echo "Returning to main menu..."
            ;;
        3)
            echo "You selected Option 3."
            # Add your code for Option 3 here
            echo "Returning to main menu..."
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
```

### Handling Reboots and Continued Processing

