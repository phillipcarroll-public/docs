# tmux Basics

### Installation

Install: `sudo pacman -S tmux`

### Session Management

Start a new session: `tmux` or `tmux new -s [name]` to name it

Detach from session: `Ctrl+b` then `d` or `tmux detach` session and related processes will continue to run

List active sessions: `tmux ls`

Reattach to sessions: `tmux attach` will attach to most recent

`tmux attach -t [name of session]` will attach to a specific session by name.

Kill a session: `tmux kill-session -t [name]`

### Window Management

Create new window: `Ctrl+b` then `c`

Switch windows: `Ctrl+b` then `n` for next, `p` for previous or a number

Rename a window: `Ctrl+b` then `,`

### Pane Management

Split vertically: `Ctrl+b` then `%`

Split horizontally: `Ctrl+b` then `"`

Navigate panes: `Ctrl+b` then use arrow keys

Close a pane: `Ctrl+b` then `x` or type `exit`

Zoom a pane: `Ctrl+b` then `z` will toggle the current pane to full screen
