# docker-dropdemo

Demostrates how to drop privileges to an arbitrary uid, while also retaining backwards compatibility with existing docker conventions

## Build

```
docker build . --tag dropdemo
```

## Run

### Option A

Run the entrypoint *and* command as uid `101`

```
docker run -it --rm --user 101 --volume "$(mktemp -d)":/example dropdemo /bin/bash -c "id && stat /example"
```
#### Output

```
[INFO] 12-13-2021 16:19:28 docker-entrypoint.sh Executing '/docker-entrypoint.d/10-fix-permissions.sh'
[INFO] 12-13-2021 16:19:28 10-fix-permissions.sh Not running as root. Skipping...
[INFO] 12-13-2021 16:19:28 docker-entrypoint.sh Finished configuration. Launching /docker-entrypoint.sh
uid=101 gid=0(root) groups=0(root)
  File: /example
  Size: 64        	Blocks: 0          IO Block: 4096   directory
Device: 76h/118d	Inode: 21197372    Links: 2
Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-12-13 16:19:28.273436127 +0000
Modify: 2021-12-13 16:19:28.273436127 +0000
Change: 2021-12-13 16:19:28.273436127 +0000
 Birth: -
```

#### Process Tree

```
$ docker run -it --rm --user 101 --volume "$(mktemp -d)":/example dropdemo ps aux
[INFO] 12-13-2021 16:46:04 docker-entrypoint.sh Executing '/docker-entrypoint.d/10-fix-permissions.sh'
[INFO] 12-13-2021 16:46:04 10-fix-permissions.sh Not running as root. Skipping...
[INFO] 12-13-2021 16:46:04 docker-entrypoint.sh Finished configuration. Launching /docker-entrypoint.sh
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
101          1  4.0  0.0   6620  1164 pts/0    Rs+  16:46   0:00 ps aux
```

### Option B

Run the entrypoint as root then immediately switch to an unprivileged uid

```
docker run -it --rm --env UID=222 --volume "$(mktemp -d)":/example dropdemo /bin/bash -c "id && stat /example"
```

#### Output
```
[INFO] 12-13-2021 16:29:29 docker-entrypoint.sh Executing '/docker-entrypoint.d/10-fix-permissions.sh'
[INFO] 12-13-2021 16:29:29 docker-entrypoint.sh Finished configuration. Launching /docker-entrypoint.sh
[INFO] 12-13-2021 16:29:29 docker-entrypoint.sh Running as root. Dropping privileges to uid 222.
uid=222 gid=222 groups=222
  File: /example
  Size: 64        	Blocks: 0          IO Block: 4096   directory
Device: 76h/118d	Inode: 21197831    Links: 2
Access: (0700/drwx------)  Uid: (  222/ UNKNOWN)   Gid: (  222/ UNKNOWN)
Access: 2021-12-13 16:29:29.106276980 +0000
Modify: 2021-12-13 16:29:29.106276980 +0000
Change: 2021-12-13 16:29:29.641184068 +0000
 Birth: -
```

#### Process Tree

```
[INFO] 12-13-2021 16:49:45 docker-entrypoint.sh Executing '/docker-entrypoint.d/10-fix-permissions.sh'
[INFO] 12-13-2021 16:49:45 docker-entrypoint.sh Finished configuration. Launching /docker-entrypoint.sh
[INFO] 12-13-2021 16:49:45 docker-entrypoint.sh Running as root. Dropping privileges to uid 222.
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
222          1  0.0  0.0   6620  1216 pts/0    Rs+  16:49   0:00 ps aux
```
