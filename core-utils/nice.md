# Core Utils - nice

`nice` is a cpu scheduling utility. The `nice` value is a priority that determines how favorable the process is when scheduled by the kernel.

Default niceness: `+10`

Run Default: `nice [some_command]`

Run high priority: `nice -n -15 [some_command]`

Run low priority: `nice -n 15 [some_command]`

| niceness | priority |
| -------- | -------- |
| -20 | Maximum |
| -19 | +++++ |
| -18 | ++++ |
| -17 | +++ |
| ... |  |
| ... |  |
| 0 | Medium |
| ... |  |
| ... |  |
| 17 | --- |
|  |  |
| 18 | ---- |
| 19 | ----- |
| 20 | Lowest |

