# Systemd Basics

Link: <a href="https://www.youtube.com/playlist?list=PLtK75qxsQaMKPbuVpGuqUQYRiTwTAmqeI">tutoriaLinux's Youtube Video Series</a>

- What is init in Linux
- General systemd theory
- Units
- Unit Files

Init = Initialization, or the first user-space process launched by the kernel after its fully booted. User-space just means things ran outside of the kernel. Init has a pid of 1 since its the first thing ran.

Init will reparent processes that become orphaned to avoid runaway zombie processes. Its core responsibilities are:

- System Bootstrapping
    - Takes care of all the startup items after the kernel is fully loaded
- Service Management
- Process Lifecycle
- Runlevel Managmeent
    - Transitions the system between single/multi user modes

Systemd was created and has replaced the `init` system and older init systems like `SysV`. 

Systemd = "System Daemon"

Much like in linux where everything is a file, in systemd everything is a unit. Unit's are abstrations of system resources, services, mounts, sockets, etc... This allows systemd to manage everything via systemctl.

Instead of starting things sequentially if there are not dependencies any/all services can start concurrently which greatly increases startup speed.

Systemd uses a graph to define dependency relationships so it can create a function order to the starting of services. You can use `systemd-analyze dot` to generate a dependency graph. 

On-Demand Activation, services can wait for a connect over a socket to arrive before starting the service.

- Systemd is an ecosystem and non-monolithic. It's a collection of bin's and lib's. 
    - PID 1 the core process replaced init
    - systemd-journald is the centralized logging component viewable with `journalctl` to replacement scattered syslog files.
    - systemd-logind managed user sessions, power events, and multi-seat setups
    - systemd-udevd handled hot plug devices (USB)
    - systemd-networkd handles network config but this is os dependent
    - systemd-resolved dns resolution
    - there are others as well

### Boot Process in Systemd

1. Kernel starts systemd and executes `/sbin/init` a symlink to `/lib/systemd/systemd`
2. Systemd mounts the filesystems, setup up cgroups for resource control and starts essential units
3. Parallel service start, basic.target then multi-user.target
4. Graphical mode if enabled, transition to graphical.target (runlevel 5) to start display manager
5. Runtime Management handled dynamic changes like starting services on demand

### Common Systemd commands

- `systemctl start/stop/restart <unit>`
    - control a single unit
- `systemctl enable/disable <unit>`
    - auto-start on boot or not
- `systemctl status <unit>`
    - view runtime info, logs, pids
- `systemctl list-units`
    - show active units
- `journalctl -u <unit>`
    - unit specific logs
- `systemctl daemon-reload`
    - reload configs after editing unit files

### Systemd Units

A unit any thing 'thing' that systemd can activate, deactivate, monitor, or manage. 

Units model relationships between services ensuring that a webserver has networking up before starting the web service. Units enable `targets` which are groups of units to orchestrate boot/start-up phases. Units support `cgroup integration` for resource limiting.

There are a large number of unit types with different roles, here are some common unit types.

- Unit types
    - `.service`
    - `.socket`
    - `.target`
    - `.target`
    - `.mount`
    - `.automount`
    - `.device`
    - `.path`
    - `.swap`
    - `.timer`
    - `.slice / .scope`

Dependencies can be declared by units via directives like:

- `After=` for order of operations
- `Requires=` for hard dependencies
- `Wants=` for soft dependencies
- `BindsTo=` to tie the lifecycle to another unit

Units can be pulled in via targets (a grouping of systemd units).

### Unit Files

These are plain-text config riles that define how systemd will manage a specific unit. Unit files have an INI like syntax with KV pairs, main sections are written in `[Brackets]`

Unit files have 3 main sections:

- Unit `[Unit]`
- Service `[Service]`
- Install `[Install]`

```ini
[Unit]
Description=Just a name
Documentation=URL/Man pages
After=Define a unit that must start before this will
Requires=Depends on this target to start (networking etc...)
Wants=Depends on but wont break this unit, just warns
[Service]
Type=simple, forking, or oneshot
ExecStart=Command to start/launch
ExecStop=Command to stop
ExecReload=Command to restart
PIDFile=Path to PID file for tracking
User=run as non-root user
Group=non root users group
Restart=This is the failure policy, always, or on-failure
#...
[Install]
WantedBy=The target that wants this unit, multi-user.target
```

### Example custom unit file

```ini
[Unit]
Description=My Simple Service
After=network.target
Documentation=https://example.com/docs

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/myservice/app.py
ExecStop=/bin/kill $MAINPID
Restart=on-failure
User=myuser
Group=mygroup

[Install]
WantedBy=multi-user.target
```

### Unit File Locations and Precedence

- `/etc/systemd/system`
    - Local customizations/overrides
    - Highest priority
- `/run/systemd/system`
    - transient, runtime generated
    - High priority
- `/usr/local/lib/systemd/system`
    - Locally installed software
    - Medium
- `/lib/systemd/system` or `/usr/lib/systemd/system`
    - Distro/package defaults
    - Lowest

Its best-practice to just create/edit in `/etc/systemd/system` to avoid conflicts.

When creating unit files:

- Create the unit file
- Reload with `sudo systemctl daemon-reload`
- Enable with `sudo systemctl enable THING`
- Start with `sudo systemctl start THING`
- Check status with `sudo systemctl status THING`
- Debug with `systemd-analyze verify THING.service`
- Logs `journalctl -u THING -f`

### NGINX Unit file example

```ini
[Unit]
Description=A high performance web server...
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### Example that starts transmission client on boot for ubuntu desktop

```ini
# /etc/systemd/system/transmission-daemon.service
[Unit]
Description=Transmission BitTorrent Daemon
After=network-online.target
Wants=network-online.target

[Service]
User=debian-transmission          # Ubuntu/Debian default system user
Group=debian-transmission
Type=simple
ExecStart=/usr/bin/transmission-daemon -f --log-error
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/lib/transmission-daemon/downloads /var/lib/transmission-daemon/incomplete

[Install]
WantedBy=multi-user.target
```