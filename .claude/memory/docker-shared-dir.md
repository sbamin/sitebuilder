---
name: docker-shared-dir
description: Docker Desktop on this Mac shares only ~/Desktop/tmp for bind mounts; /tmp mounts fail
metadata:
  type: reference
---

Docker Desktop file sharing allows bind mounts only from `~/Desktop/tmp`. Mounts from `/tmp` fail with "mounts denied". Use `mktemp -d ~/Desktop/tmp/X.XXXX` for container work dirs (e.g. `bundle lock --update` in a ruby container, since host ruby is 2.6). Related: [[no-docker-without-asking]].
