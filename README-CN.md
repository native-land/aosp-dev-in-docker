# aosp-dev-in-docker
我的Docker配置用于容器化AOSP开发。

## 要求
* Ubuntu 25.04（我确信早期版本或其他发行版也可能工作——我只是没有测试过）。
* Docker Desktop 4.43.0或更高版本（早期版本也可能工作；你试用时就会知道）。
    * Docker Engine可能就足够了。我没有运行Docker Desktop应用程序。到目前为止，我只是运行了普通的`docker`命令。话虽如此，可能Docker Engine就是你所需要的全部。

## 设置
* 假设你满足要求，打开一个终端窗口。
* 进入这个仓库目录（例如，`$ cd this/repo/directory`）。
* 创建`aosp`镜像：
```console
$ sudo docker build -t aosp .
```
> [!IMPORTANT]  
> 注意`sudo`的使用。这是合理的，因为在Ubuntu主机上构建AOSP需要管理员权限。这都是关于[非特权用户命名空间](https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces)（Ubuntu 23.10引入的功能）。我正在研究一个可能不需要`sudo`的解决方案。但是，这目前是_低优先级_的。我必须首先让AOSP环境工作。
* 基于该镜像创建`aosp-dev`容器：
```console
$ sudo docker create --name aosp-dev --interactive --privileged aosp:latest
```
<!-- 参数详解：
  sudo：以管理员权限运行，因为构建AOSP需要特权访问
  docker create：创建新容器但不启动它
  --name aosp-dev：为容器指定名称为"aosp-dev"，便于后续引用
  --interactive：保持STDIN开放，允许交互式操作
  --privileged：赋予容器完全的主机访问权限，AOSP构建需要此权限
  aosp:latest：指定要使用的基础镜像和标签
-->
> [!IMPORTANT]  
> 检查这里是否可以省略`--privileged`，只要我们在执行脚本`build-aosp.sh`时发出即可（这在那里真正重要）。
* 你将收到一个容器ID。但是，`aosp-dev`是一个更好的名称来引用它。容器已创建，但没有运行。
* 如果你运行命令，你仍然可以看到它
```console
$ sudo docker ps --all
```
* 创建时，`STATUS`列应该显示`Created`。

## 启动容器
* 对于这个旅程的其余部分，我们需要容器运行。你总是可以用以下命令启动它：
```console
$ sudo docker start aosp-dev
```
* 现在，当你运行`docker ps`时（不需要请求`--all`，因为`ps`默认列出所有正在运行的容器），`STATUS`列应该显示`Up ...`后跟正常运行时间。
* 每次你想在容器中发生某些事情时，你必须确保它已启动。
> [!NOTE]  
> 当你完成并且在下次之前不需要容器运行时，你可以用以下命令停止它
```console
$ sudo docker stop aosp-dev
```

## 获取AOSP代码库
* AOSP代码库基于一系列Git仓库。有一个工具可以编排所有这些。它的名字是`repo`。幸运的是，`aosp`镜像已经包含了它（以及Git和工具链的其余部分）。
* 要获取AOSP源文件，在终端上运行此命令：
```console
$ sudo docker exec --interactive --tty --workdir /aosp aosp-dev get-aosp.sh --git-user "Your Name" --git-email your@email.dev 
```
<!-- 参数详解：
  sudo：以管理员权限运行
  docker exec：在运行中的容器内执行命令
  --interactive：保持STDIN开放，允许交互式操作
  --tty：分配一个伪终端（TTY），提供终端环境
  --workdir /aosp：设置容器内的工作目录为/aosp
  aosp-dev：目标容器名称
  get-aosp.sh：要执行的脚本文件
  --git-user "Your Name"：设置Git用户名，用于代码仓库操作
  --git-email your@email.dev：设置Git邮箱，用于代码仓库操作
-->
* 这些git参数`--git-user`（或`-u`）和`--git-email`（或`-e`）只在第一次需要。如果出于任何原因你需要重新运行`get-aosp`脚本，你可以省略这些。
> [!TIP]  
> `--sync-jobs <number>`，或者`-j <number>`是另一个参数，它指定有多少个并发工作者将同时拉取仓库。当省略时，假定为4（四）。

## 构建AOSP代码库
* 确保你已经启动了`aosp-dev`容器，在主机终端上发出以下命令：
```console
$ sudo docker exec --interactive --tty --privileged --workdir /aosp aosp-dev build-aosp.sh
```
<!-- 参数详解：
  sudo：以管理员权限运行，确保有足够权限进行构建操作
  docker exec：在运行中的容器内执行命令
  --interactive：保持STDIN开放，允许交互式操作
  --tty：分配一个伪终端（TTY），提供终端环境
  --privileged：赋予容器完全的主机访问权限，AOSP构建过程需要此权限
  --workdir /aosp：设置容器内的工作目录为/aosp
  aosp-dev：目标容器名称
  build-aosp.sh：要执行的构建脚本文件
-->
> [!TIP]  
> `--sync-jobs <number>`，或者`-j <number>`指定有多少个并发工作者将同时构建AOSP。当省略时，假定为4（四）。
* 它构建`aosp_cf_x86_64_only_phone-aosp_current-userdebug`版本。一个基于x86_64架构的Cutterfish启用的手机目标，包含所有调试符号。
> [!NOTE]  
> 我将扩展此脚本以启用`--lunch`或`-l`参数来更改此默认值。 