# vim Basics

**Write this with vim dummy**

vim and Neovim is based on vi. While vim is based on vi, it was built on its own codebase.

- vi: released in 1976
    - Built for Unix
    - vi = visual in reference to the ex command
- vim: release in 1991
    - Build for Amiga
    - Vi IMproved or Vi Imitation
- Neovim: released in 2014-2015
    - Fork of vim
    - Further extends features and scripting over vanilla vim

### Enable Syntax Highlighting

```bash
sudo vim /etc/vimrc
```

Add the following to the end of `vimrc`

```bash
syntax on
```

Save and exit with: `:x`

### Moving The Cursor

When in `i` insert mode you can use the arrow keys.

When outside that mode use the following:

- `h` move cursor left
- `j` move cursor down
- `k` move cursor up
- `l` move cursor right

We can also move x number of characters by typing a number and the corresponding move cursor key:

To create the following text to show this we need to copy and paste the 4 previous bullet points.

Start on the "move cursor left" line:

Copy a single line: `yy`

We want to copy 4 lines: `4yy`

4 lines were yanked, we should be able to paste it with the following:

- `p` Paste before the cursor 
- `P` Paste after the cursor

I used `p`, we can now see the pasted and then modified lines below.

- `5h` move cursor left 5 characters
- `2j` move cursor down 2 lines
- `3k` move cursor up 3 lines
- `7l` move cursor right 7 characters

So we have learned:

- How to move the cursor around
- Move the cursor by x lines or characters
- Copy a single or multiple lines
- Paste those lines

### Copy/Paste Text

We will use the following line as our test:

```bash
./make tac ack
```

I just want to grab `tac` we can use:

- `yaw` to copy the word with the trailing whitespace
- `yiw` to copy the word without its trailing whitespace

We should have this copied, we need to paste it: tac

That worked pretty well. 

What if we just wanted to select a few letters from a work? I think this would be "Marking" text in vim, not sure since we are literally learning this day one. 

It looks like we can mark individual characters with: `v`

Our test word: "abc123def" I just want to grab the "123" and paste below.

Output: `123`

Ok some takeaways here, I messed up a few times and was able to delete the bad Output with `dw` to delete the word. But the usage of Mark/Yank is pretty simplement. In my terminal I cursor to `1`, press `v` to mark, then 'l' over until the cursor is underscoring '3' which will not be highlighted. Then `y` to yank/copy the marked word/characters. Finally `p` to paste.

### Undo and Redo

- undo: `u`
- undo last changes in line: `U`
- redo: `Ctrl+r`

Undo looks like it rips out anything you wrote between the last `INSERT`

At the end of this test you should only see:

`this`

This should get removed with either `U` or `:undo:`

We definitely need some more practice to make this a little more brain native but as far as using undo and redo its not difficult, just need to under stand how far the undo will reach seems to be isolated to the last INSERT.

### Searching

Pretty simple:

- `/pattern` forward search
- `?pattern` backwards search
- `*` next instance of word
- `#` next instance of word
- `n` repeat search in same direction
- `N` repeat search in opposite direction

### Commands and Keys

| Category | Key | What does it do? |
| --- |  --- | --- |
| Save/Quit | :x | save and quit |
| Save/Quit | :wq | save and quit |
| Save/Quit | :w | save |
| Save/Quit | :q! | quit without saving |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Moving | h | move cursor left |
| Moving | j | move cursor down |
| Moving | k | move cursor up |
| Moving | l | move cursor right |
| Moving | #h [j/k/l] | move in a specified direction multiple times |
| Moving | b / B | move to start of a word / token |
| Moving | w / W | move to the start of the next word / token |
| Moving | e / E | move to the end of a word / token |
| Moving | 0 | jump to the beginning of line |
| Moving | $ | jump to the end of line |
| Moving | ^ | jump to the first (non-blank) character of line |
| Moving | #G / #gg / :# | move to a specified line number (replace # with the line number) |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Moving Screens | Ctrl+b | move back 1 screen |
| Moving Screens | Ctrl+f | move forward 1 screen |
| Moving Screens | Ctrl+d | move forward .5 screen |
| Moving Screens | Ctrl+u | move back .5 screen |
| Moving Screens | Ctrl+e | move screen down one line (cursor stays put) |
| Moving Screens | Ctrl+y | move screen up one line (cursor stays put) |
| Moving Screens | Ctrl+o | move backward through the jump history |
| Moving Screens | Ctrl+i | move forward through the jump history |
| Moving Screens | H | move to the top of the screen |
| Moving Screens | M | move to the middle of the screen |
| Moving Screens | L | move to the bottom of the screen |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Searching | * | jump to the next instance of a word |
| Searching | # | jump to the previous instance of a word |
| Searching | /pattern | search forward for the pattern |
| Searching | ?pattern | search backward for the pattern |
| Searching | n | repeat the search in the same direction |
| Searching | N | repeat the search in the opposite direction |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Inserting | i | switch to insert mode before the cursor |
| Inserting | I | insert text at the beginning of the line |
| Inserting | a | switch to insert mode after the cursor |
| Inserting | A | insert text at the end of the line |
| Inserting | o | open a new line below the current one |
| Inserting | O | open a new line above the current one |
| Inserting | ea | insert text at the end of the word |
| Inserting | Esc | exit insert mode |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Editing | r | replace a single character and move to command mode |
| Editing | cc | replace entire line and move to insert mode |
| Editing | C / c$ | replace from cursor to the end of the line |
| Editing | cw | replace from cursor to the end of the word |
| Editing | s | delete a character and move to insert mode |
| Editing | j | merge with line below, single space between |
| Editing | J | merge with line below, with no space between |
| Editing | . | repeat last command |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Undoing/Redoing | u / :u / :undo | undo changes made in last entry |
| Undoing/Redoing | #u | undo multiple changes |
| Undoing/Redoing | U | undo latest changes in line |
| Undoing/Redoing | Ctrl+r | redo the last undone entry |
| Undoing/Redoing | #Ctrl+r | redo multiple changes |
| Undoing/Redoing | :undolist | list undo branches |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Deleting | dd / D | delete a single line |
| Deleting | dw | delete a single word |
| Deleting | #dd / d#d | delete multiple lines |
| Deleting | :#,#d | delete a range of lines |
| Deleting | :%d | delete all lines |
| Deleting | :.,$d | delete from current line to end of the file |
| Deleting | dgg | delete from current line to start of the file |
| Deleting | :g /pattern/d | delete lines contained a specified pattern |
| Deleting | :g!/pattern/d | delete lines that do not contain a pattern |
| Deleting | :g/^$/d | delete all blank lines |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Copying | yy | copy an entire line |
| Copying | #yy | copy specified number of lines |
| Copying | yaw | copy a word with its trailing whitespace |
| Copying | yiw | copy a word without its trailing whitespace |
| Copying | y$ | copy everything right of cursor |
| Copying | y^ | copy everything left of cursor |
| Copying | ytx | copy everything between cursor and specified char (x) |
| Copying | yfx | copy everything between cursor and a specified char including the char (x) |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Cutting | dd | cut the entire line |
| Cutting | #dd | cut a specified number of lines |
| Cutting | d$ | everything to the right of the cursor |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Pasting | p | paste text after the cursor (lower p) |
| Pasting | P | paste text before the cursor |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Marking | v | marking text using character mode |
| Marking | V | mark lines using line mode |
| Marking | Ctrl+v | mark text using block mode |
| Marking | o | move from one end of the marked text to the other |
| Marking | aw | mark a word |
| Marking | ab | mark a block with () |
| Marking | aB | mark a block with {} |
| Marking | at | mark a block with <> |
| Marking | ib | mark inner block () |
| Marking | iB | mark inner block {} |
| Marking | it | mark inner block <> |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Visual Commands | y | yank (copy) the marked text |
| Visual Commands | d | delete (cut) the marked text |
| Visual Commands | p | paste the text after the cursor (lower) |
| Visual Commands | u | change the marked text to lowercase |
| Visual Commands | U | change the marked text to uppercase |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Color Schemes | :colorscheme [name] | change to specified scheme |
| Color Schemes | :colorscheme [space]+Ctrl+d | list available vim colorschemes |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Marks and Jumps | m[a-z] | marking text using chracter mode from a to z |
| Marks and Jumps | m[a-z] | mark lines using line mode from a to z |
| Marks and Jumps | `a | jump to position marked with a |
| Marks and Jumps | `y`a | yank text TO position marked a |
| Marks and Jumps | `. | jump to last change in file |
| Marks and Jumps | `" | jump to last edit in file |
| Marks and Jumps | `0 | jump to position where vim was last exited |
| Marks and Jumps | `` | jump to last jump |
| Marks and Jumps | :marks | list all marks |
| Marks and Jumps | :jumps | list all jumps |
| Marks and Jumps | :changes | :list all changes |
| Marks and Jumps | Ctrl+i | move to next instance in jump list |
| Marks and Jumps | Ctrl+o | move to previous instance in jump list |
| Marks and Jumps | g. | move to next instance in change list |
| Marks and Jumps | g: | move to previous instance in change list |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Macros | qa | record macro a |
| Macros | q | stop recording macro |
| Macros | @a | run macro a |
| Macros | @@ | run last macro again |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |
| Multiple Files | :e file_name | open a file in a new buffer |
| Multiple Files | :bn | move to next buffer |
| Multiple Files | :bp | go back to previous buffer |
| Multiple Files | :bd | close buffer |
| Multiple Files | :b# | move to the specified buffer (by number) |
| Multiple Files | :b file_name | move to the specified buffer (by name) |
| Multiple Files | :ls |  st all buffers|
| Multiple Files | :sp file_name | open a file in a new buffer and split the viewpoint horizontally |
| Multiple Files | :vs file_name | open a file in a new buffer and split the viewpoint veritcally |
| Multiple Files | :vert ba | edit all files as vertical viewports |
| Multiple Files | :tab ba | edit all buffers as tabs |
| Multiple Files | gt | move to next tab |
| Multiple Files | gT | move to previous tab |
| Multiple Files | Ctrl+ws | split viewport horizontally |
| Multiple Files | Ctrl+wv | split viewport vertically |
| Multiple Files | Ctrl+ww | switch viewports |
| Multiple Files | Ctrl+wq | quit a viewport |
| Multiple Files | Ctrl+wx | exchange current viewport with next one |
| Multiple Files | Ctrl+= | make all viewports equal height and width |
| \ (^_^) / | \ (^_^) / | \ (^_^) / |

# Vim As Your Editor - ThePrimeagen

<a href="https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R&index=1">Vim As Your Editor Youtube Playlist</a>

- Normal mode - move cursor
- Insert mode - type like an editor
    - `i`
- Visual mode - Highlighting with cursor
    - `v`
        - character-wise mode
    - `V`
        - line-wise visual mode
        - V, y to copy line, then p will paste the line with the return, making new lines
    - `Ctrl + v`
        - Block-wise visual mode aka Column mode
- Command mode - `:thing`

Exit any visual mode with `Esc` or `Ctrl + c`

- Basic Vim Navigation
    - `h` - left
    - `j` - down
    - `k` - up
    - `l` - right
- Essential Vim Motions (Anything that moves cursor is a motion)
    - `w` - Next word
    - `b` - Previous word
    - `0` - Start of line (Zero)
    - `gg` - Top of file
    - `G` - Bottom of file
    - `x` - Delete/Cut
    - `a` - Move forward one char and enter Insert Mode


