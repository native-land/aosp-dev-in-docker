# aosp-dev-in-docker
My Docker configuration to containerize AOSP development.

## Requirements
* Ubuntu 25.04 (I'm sure earlier versions or other distros may also work -- I just haven't tested it).
* Docker Desktop 4.43.0 or later (earlier versions may also work; you'll know when you try).
    * There's a chance that Docker Engine is enough. I haven't run the Docker Desktop app. I ran the plain vanilla `docker` command so far. That said, odds are that Docker Engine is all you need.

## Setup
* Assuming that you meet the requirements, open a terminal window.
* Go to this repo directory (e.g., `$ cd this/repo/directory`).
* Create the `aosp` image:
```console
$ sudo docker build -t aosp .
```
> [!IMPORTANT]  
> Notice the `sudo` usage. This is justified by the fact that building AOSP on an Ubuntu host requires admin privileges. It's all about [unprivileged user namespaces](https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces) (a feature introduced on Ubuntu 23.10). I'm working on a possible solution that would not require `sudo`. However, it's _low priority_ for now. for now. I must get the AOSP environment working first.
* Create the `aosp-dev` container based on that image:
```console
$ sudo docker create --name aosp-dev --interactive --privileged aosp:latest
```
> [!IMPORTANT]  
> Check if `--privileged` can be omitted here, provided that we'll issue when executing the script `build-aosp.sh` (where it really matters).
* You'll receive a container ID. However, `aosp-dev` is a better name to refer to it. The container is created, but it's not running.
* You can still see it if you run the command
```console
$ sudo docker ps --all
```
* When created, the `STATUS` column should read `Created`.

## Starting the Container
* For the rest of this journey, we'll need the container to be running. You can always start it with the following command:
```console
$ sudo docker start aosp-dev
```
* Now, when you run `docker ps` (no need to request `--all`, provided that `ps` lists all running containers by default), the `STATUS` column should read `Up ...` followed by an uptime.
* Every time you want something to happen in the container, you must make sure it's started.
> [!NOTE]  
> When you're done and don't need the container running until the next time, you can stop it with
```console
$ sudo docker stop aosp-dev
```

## Acquiring the AOSP Codebase
* The AOSP codebase is based on a constellation of Git repositories. There's a tool that orchestrates all. Its name is `repo`. Happily, the `aosp` image already contains it (as it does with Git and the rest of the toolchain).
* To get AOSP source files, run this command on a terminal:
```console
$ sudo docker exec --interactive --tty --workdir /aosp aosp-dev get-aosp.sh --git-user "Your Name" --git-email your@email.dev 
```
* These git parameters `--git-user` (or `-u`) and `--git-email` (or `-e`) are needed only for the first time. If, for any reason, you need to re-run the `get-aosp` script, you can omit these.
> [!TIP]  
> `--sync-jobs <number>`, or just `-j <number>` is another parameter that specifies how many concurrent workers will pull the repo simultaneously. When omitted, 4 (four) is assumed.

## Build the AOSP Codebase
* Ensuring that you have started an `aosp-dev` container, issue the following command on a host terminal:
```console
$ sudo docker exec --interactive --tty --privileged --workdir /aosp aosp-dev build-aosp.sh
```
> [!TIP]  
> `--sync-jobs <number>`, or just `-j <number>` specifies how many concurrent workers will build AOSP simultaneously. When omitted, 4 (four) is assumed.
* It builds the `aosp_cf_x86_64_only_phone-aosp_current-userdebug` flavor. A Cutterfish-enabled phone target based on an x86_64 architecture with all the debug symbols.
> [!NOTE]  
> I'll extend this script to enable a `--lunch` or `-l` param to change this default.
