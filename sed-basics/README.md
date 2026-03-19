# `sed` Basics

**sed** = stream editor

Bell Labs utility that was part of the early unix toolkit. Evolved from the early editor `ed`. sed is mostly unchanged over the decades. 

sed was designed to transform text streams rather than edit files interactively. This means its useful for filtering/manipulating text data in files and streams via pipes. sed is ideal for searching for and replacing text with patterns, inserting, or deleting specific lines. It can also be useful to extract meaningful text from files. 

Like a lot of text processing tools `sed` processes input line by line. It will apply your commands to each line reading from `stdin` or files and outputs from `stdout`. 

### Common `sed` tasks

- substitution
    - `s/` to find and replace text patterns
    - `sed 's/old/new/' myfile`
- deletion
    - `d` to find a pattern to remove
    - `sed '/removethispattern/d' myfile`
- insertion/appending
    - `-i` to insert (insert at line)
        - `sed -i '5i\add at 5th line' myfile`
    - `a` to append (append after line)
        - `set '5a\text added after 5th line' myfile`
- printing
    - `p` to print specific lines
    - `sed -n '5p' myfile` to print the 5th line
- range addressing
    - Address a specific range of lines of text
    - Delete first 10 lines
        - `sed '1,10d' myfile`

`-i` in the above example means to edit the file in place.

### regex

sed supports regex so for specific pattern matching for things like IP addressing we can simply swap out the 3rd octet.

If we have a file of IP addresses, and we are migrating those devices to a new network and we have to modify some file where every ip's 3rd octet needs to change we can do the following:

myipfile

```bash
10.0.0.1
10.0.0.2
10.0.0.3
...
10.0.0.100
```

We could use sed for a straight replacement since our IP schema is so simple: `sed -i 's/10.0.0/10.0.100/' myipfile` this would essentially accomplish the exact thing we want to do. Replace the 3rd octet `0` with `100` but lets do this with regex.

Note, there are different flavors of regex BRE and ERE which can be used in `sed`. 

- BRE
    - Basic Regular Expressions
    - special characters need a `\` to be special
        - `+, ?, |, {}, ()`
- ERE
    - Extended Regular Expressions
    - special characters do not need a `\` to be special
    - use `\` on special characters to make then literal
    - `+` can represent one or more, and more advanced features

We will use ERE by adding the tag `-E` to our `sed` command.

Our example: `sed -i -E 's/^([0-9]{1,3}\.){2}0(\.[0-9]{1,3})$/\1100\2/' myipfile`

Regex is very ugly, lets break this down:

```bash
s/ # Start of the sed substitution 

^ # start of the line

([0-9]{1,3}\.) # matches 1 to 3 digits following by a ., a single octet. For this command this is group 1.

# Lets break this group 1 chunk down

() # contains the group, capturing all the 'things' we want to match

[0-9] # this is a character class, matches any single digit 0 to 9

# But if we only capture a single digit how do we capture an octect, we do this with the next line

{1,3} # this is the quantifier that uses the preceding [0-9] element and applies them to 1 to 3 characters

\. # this is the period at the end of the octet, the special character must be escaped with \

### OK now we understand how we can capture 10. or 192. how can we select more of the IP

{2} # this repeats the first group twice, so it should catch 10.0., or 192.168. etc...

0 # This matches the string literal in the 3rd octet, which is "0", if we wanted to match 100, we would put 100 here.

# Now we need to grab the last dot and 4th octet.

(\.[0-9]{1,3}) # This is now group 2 and matches the . and IP in the 4th octet

$ # this represents the end of the line

# At this point our regex is complete, but we must replace the thing we selected with the regex. We essentially captured octets 1,2 and 4 in group 1 and 2.

/\1100\2/ # This looks a little confusing, lets break it down

/ # the opening / is the start of the what will be used to substitute

\1 # start the substitute with group 1, which is the first 2 octets we matched with regex

100 # this is the text that will substitute the 3rd octet, our goal

\2 # add group 2 which should be what we matched in the 4th octet

/ # end the substitution
```