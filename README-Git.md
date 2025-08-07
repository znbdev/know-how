Git
=====

# Install

```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew search git
brew install git
brew upgrade git
# brew link 将 git 指向我们通过 Homebrew 安装的 git
brew link git --overwrite
brew uninstall git
git --version
```

# Add key to local

```shell
ssh-agent bash
ssh-add -l
ssh-add -K ~/.ssh/znbdev_rsa
ssh-add -K ~/.ssh/id_rsa
```

# Local default git user settings

```shell
git config --list
#git config --system --list
#git config --global --list
git config --global --edit
#git config --local --list
git config --global user.name "znbdev"
git config --global user.email "znbdev@outlook.com"
git config --global http.proxy dev-proxy.db.?????.co.jp:9501
git config --global https.proxy dev-proxy.db.?????.co.jp:9501
```

# Edit git config

```shell
git config --edit
e.g.)
[user]
email = znbdev@outlook.com
name = znbdev
```

# 您可以通过以下步骤更改 GitHub 上先前提交的用户名

进入您的本地代码库，并使用以下命令查看先前提交的历史记录

```shell
git log
```

使用以下命令更改提交的用户名和电子邮件

```shell
git filter-branch -f --commit-filter '
if [ "$GIT_COMMITTER_NAME" = "znbsys" ];
then
    GIT_COMMITTER_NAME="znbdev";
    GIT_AUTHOR_NAME="znbdev";
    GIT_COMMITTER_EMAIL="znbdev@outlook.com";
    GIT_AUTHOR_EMAIL="znbdev@outlook.com";
    git commit-tree "$@";
else
    git commit-tree "$@";
fi' HEAD
```

执行命令后，您需要将修改的提交强制推送到 GitHub 上的仓库。使用以下命令：

```shell
git push --force
```

# Command

```shell script
# checkout branch
git checkout -b master remotes/origin/master
git checkout -b dev remotes/origin/dev

# commit
git commit --amend --author="znbdev <znbdev@outlook.com>"

# clean all modify 删除本地修改
git checkout . && git clean -xdf
git reflog --date=local | grep master
git branch -d 

# git删除远程分支提交记录(reset回去然后强推)
# 删除的记录的前面的一条记录
git reset --hard HEAD^
# 强推
git push --force origin HEAD

# 删除到指定一条记录
git log
git reset -hard xxxxxx
git push -force origin HEAD

# 回滚到上一个commit
git reset --hard head^
```

# 撤销远程提交

```shell
# 使用
git reset --hard head^
# 回滚到上一个commit

# 使用
git status
# 查看现在的工作区情况，提示Your branch is behind 'origin/master' by 1 commit,代表成功表了上一次的提示状态
# nothing to commit, working tree clean代表这次的修改全没了，清理的算是一个彻底。如果还想找回来怎么办，我们还真是有办法让你找回来的，以后的推送救命的后悔药会详细讲述。

# 这个时候我们再把他强制推送到远程：
git push origin master --force
git push origin qa/Refactor_EJC_batch --force
git push origin HEAD --force
# 命令强制提交到远程仓库(注意，如果是在团队合作的情况下，不到迫不得已不要给命令加--force参数
```

# 将当前分支修改暂存

```shell
# 暂存本分支的修改
git stash
# 显示所有 stash 的数据
git stash list

# 恢复修改
# 恢复最近一次暂存的修改
git stash apply
# /恢复索引 stash@{2} 对应的暂存的修改，索引可以通过 git stash list 进行查看
git stash apply stash@{2}
# 在恢复暂存数据时尽量恢复至原状态( 已经 staged 状态的文件仍恢复为 staged 状态 )
git stash apply --index

# 删除修改
# 删除 stash@{1} 分支对应的缓存数据
git stash drop stash@{1}
# 将最近一次暂存数据恢复并从栈中删除
git stash pop
```

```shell
git filter-branch --env-filter '
 
an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"
 
if [ "$GIT_COMMITTER_EMAIL" = "xxxxx@xxxxx.com" ]
then
    cn="znbdev"
    cm="znbdev@outlook.com"
fi
if [ "$GIT_AUTHOR_EMAIL" = "xxxxx@xxxxx.com" ]
then
    an="znbdev"
    am="znbdev@outlook.com"
fi
 
export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
'
```

# 在 Mac 上，可以使用 ssh-agent 来管理私钥，并且能够在重启后自动重新加载私钥。

````shell script
# 打开终端，输入以下命令启动 ssh-agent：
eval "$(ssh-agent -s)"
# 添加私钥到 ssh-agent：
ssh-add ~/.ssh/id_rsa

为了让 ssh-agent 在重启后自动重新加载私钥，需要在每次登录时运行 ssh-agent。
打开 "系统偏好设置" -> "用户与群组"
选择你的用户，点击 "登录项"
点击"+"号按钮
在弹出的窗口中输入： ssh-agent
命令： eval "$(ssh-agent -s)"
# 重启系统，登录后确认 ssh-agent 已经自动加载了私钥

ssh-add -l
````

```shell
# 打开一个新的Shell窗口,重新连接服务器
ssh git@github.com
```

```shell
# 重置本地仓库到远程仓库的最新版本
git fetch --all
git reset --hard origin/master
```

Git 回滚到前一个 commit 并强制推送到远程是一个**有风险的操作**，因为它会**修改 Git 历史记录**
。在多人协作的项目中，这可能导致其他协作者的代码出现问题。**请务必谨慎操作，并在执行前与团队成员沟通。**

通常，有两种主要方法可以回滚 Git commit：

1. **`git reset --hard` (修改历史记录，慎用)**：
   这种方法会**彻底删除**从指定 commit 之后的所有本地提交，并且工作区和暂存区也会回到那个 commit
   的状态。如果你确定不再需要后续的提交，并且理解其对历史记录的影响，可以使用此方法。

    * **步骤 1：回滚本地仓库到前一个 commit**

      ```bash
      git reset --hard HEAD^
      ```

      这个命令会将你的本地分支的 `HEAD` 指针移动到当前 commit 的前一个 commit。

        * `HEAD^` 指的是当前 `HEAD` 的前一个 commit。你也可以使用 `HEAD~1` 来表示同样的意思。
        * 如果你想回滚到更早的 commit，可以使用 `HEAD~N` (N 是你要回滚的 commit 数量，例如 `HEAD~3` 回滚到前 3 个 commit)。
        * 或者，你也可以使用具体的 commit hash：
          ```bash
          git reset --hard <commit_hash>
          ```
          你可以通过 `git log` 命令查看 commit hash。

    * **步骤 2：强制推送修改到远程仓库**

      ```bash
      git push --force origin <你的分支名称>
      ```

      或者，如果你使用的是 Git 2.0 以后版本，更推荐使用：

      ```bash
      git push --force-with-lease origin <你的分支名称>
      ```

      `--force-with-lease` 比 `--force` 更安全一些，因为它会在推送前检查远程分支是否与本地分支同步，防止你在别人推送了新的
      commit 之后错误地覆盖掉他们的工作。

      **重要提示：**

        * \*\*`--force` 或 `--force-with-lease` 会覆盖远程仓库的历史。\*\*这意味着远程仓库上回滚点之后的所有提交都将被删除。
        * 如果其他人在你强制推送之前已经基于你将要回滚的 commit 进行了工作，他们的本地仓库将与远程仓库不一致，需要进行额外的操作（例如
          `git pull --rebase`）才能与新的远程历史同步。

-----

2. **`git revert` (推荐，保留历史记录)**：
   `git revert` 是一个更安全的选项，尤其是在**多人协作**的项目中。它不会修改现有的历史记录，而是**创建一个新的 commit 来撤销指定
   commit 所做的更改**。这意味着你的 Git 历史记录是线性的，并且可以清楚地看到撤销操作。

    * **步骤 1：撤销前一个 commit**

      ```bash
      git revert HEAD
      ```

      这个命令会创建一个新的 commit，其内容是将前一个 commit (也就是当前 `HEAD` 所指向的 commit) 的所有更改反向应用。
      执行此命令后，Git 会打开一个编辑器让你编辑撤销 commit 的提交信息，保存并退出即可。

    * **步骤 2：推送新的撤销 commit 到远程仓库**

      ```bash
      git push origin <你的分支名称>
      ```

      由于 `git revert` 是新增一个 commit，而不是修改历史，所以不需要使用 `--force`。

-----

### 总结与选择建议：

* **什么时候使用 `git reset --hard` + `git push --force`？**

    * 当你只在**本地工作**，并且确定要彻底丢弃后续提交时。
    * 当你**在非常早期**发现错误，并且可以与所有协作者沟通并协调时。
    * **绝对不要**在公共的、已经被多人克隆和工作的分支上随意使用，除非你完全清楚其后果并且所有人都已做好准备。

* **什么时候使用 `git revert`？**

    * **强烈推荐**在**多人协作**的项目中使用，尤其是在公共分支上。
    * 当你希望保留完整的 Git 历史记录，并且只是想撤销某个 commit 的影响时。
    * 当你只想撤销特定 commit 的更改，而保留其后的其他 commit 时。

**在执行任何回滚操作之前，强烈建议您：**

1. **备份你的工作：** 比如将当前分支打包或者复制一份代码到其他地方，以防万一。
2. **确认当前分支的状态：** 使用 `git status` 和 `git log` 了解当前分支的情况。
3. **与团队沟通：** 如果是团队项目，务必与团队成员沟通，避免造成不必要的冲突和麻烦。

# Reference

[gitconfig の基本を理解する](https://qiita.com/shionit/items/fb4a1a30538f8d335b35)

[The entire Pro Git book](https://git-scm.com/book/zh/v2)

[撤销远程提交](https://zhuanlan.zhihu.com/p/65491310)

[Adding a new SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
