# Core Utils - tee

`tee` will read from a standard input and simultaneously write to a standard output and one or more files. 
tee comes from the letter `T` which looks like a junction in a literal pipeline, as in plumbing. `tee` acts as a junction in the data pipeline in linux. This allows data to flow through a pipe while also capturing the data in a file. 

This is just a simplification. 

```bash
command | ===**=== standard out
             ||
             ||
             ||
         tee options
```

Get info from the output of a command and also write it to a file:

```bash
ls -al | tee output.txt
```

Write the output to multiple files as args:

```bash
ls -al | tee output1.txt output2.txt output3.txt
```

Get output of a command while piping to another command:

```bash
dmesg | tee boot.log | grep "error"
```

TLDR: Use it when you need to get the standard out but also pass the output to a file.
