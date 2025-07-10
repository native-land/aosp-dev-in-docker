# aosp-dev-in-docker
My Docker configuration to containerize AOSP development.

## Requirements
* Ubuntu 25.04 (I'm sure earlier versions or other distros may also work -- I just haven't tested it).
* [Docker Desktop](https://docs.docker.com/get-started/get-docker/) 4.43.0 or later (earlier versions may also work; you'll know when you try).
* Make sure to launch the Docker Desktop GUI and accept the license agreement.

## Setup
* Assuming that you meet the requirements, open a terminal window.
* Go to this repo directory (e.g., `$ cd this/repo/directory`).
* Copy the file `docker.apparmor` to `/etc/apparmor.d`:
```console
$ sudo cp docker.apparmor /etc/apparmor.d/docker
```
* This file gives an isolated environment to `docker`, circumvecting Ubuntu's unprivileged user namespace (`userns`) restrictions.
* Reload the AppArmor service so it takes the moved file without rebooting the whole system. On Ubuntu, reloading a service has the following shape:
```console
$ sudo systemctl reload apparmor.service
```
* Create the `aosp` image:
```console
$ docker build -t aosp .
```
* Create the `aosp-dev` container based on that image:
```console
$ docker create --name aosp-dev --interactive aosp:latest
```
* You'll receive a container ID. However, `aosp-dev` is a better name to refer to it. The container is created, but it's not running.
* You can still see it if you run the command
```console
$ docker ps --all
```
* When created, the `STATUS` column should read `Created`.

## Starting the Container
* For the rest of this journey, we'll need the container to be running. You can always start it with the following command:
```console
$ docker start aosp-dev
```
* Now, when you run `docker ps` (no need to request `--all`, provided that `ps` lists all running containers by default), the `STATUS` column should read `Up ...` followed by an uptime.
* Every time you want something to happen in the container, you must make sure it's started.
> [!NOTE]  
> When you're done and don't need the container running until the next time, you can stop it with
```console
$ docker stop aosp-dev
```

## Acquiring the AOSP Codebase
* The AOSP codebase is based on a constellation of Git repositories. There's a tool that orchestrates all. Its name is `repo`. Happily, the `aosp` image already contains it (as it does with Git and the rest of the toolchain).
* To get AOSP source files, run this command on a terminal:
```console
$ docker exec --interactive --tty aosp-dev get-aosp.sh --git-user "Your Name" --git-email your@email.dev
```
* These git parameters `--git-user` (or `-u`) and `--git-email` (or `-e`) are needed only for the first time. If, for any reason, you need to re-run the `get-aosp` script, you can omit these.
> [!TIP]  
> `--sync-jobs <number>`, or just `-j <number>` is another parameter that specifies how many concurrent workers will pull the repo simultaneously. When omitted, 4 (four) is assumed.

## Build the AOSP Codebase
* Ensuring that you have started an `aosp-dev` container, issue the following command on a host terminal:
```console
$ docker exec --interactive --tty aosp-dev build-aosp.sh
```
> [!TIP]  
> `--sync-jobs <number>`, or just `-j <number>` specifies how many concurrent workers will build AOSP simultaneously. When omitted, 4 (four) is assumed.
* It builds the `aosp_cf_x86_64_only_phone-aosp_current-userdebug` flavor. A Cutterfish-enabled phone target based on an x86_64 architecture with all the debug symbols.
> [!NOTE]  
> I'll extend this script to enable a `--lunch` or `-l` param to change this default.
