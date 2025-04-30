# git  其他操作

在使用git一段时间后，再学习git的文档，发现一些不常用但是也很好用的命令。



### git switch   切换分支  

是新版本提供的切换分支命令，作用与 [git checkout](https://www.runoob.com/git/git-checkout.html) 类似，但提供了更清晰的语义和错误检查。

**创建新分支并切换**

如果你想同时创建一个新分支并切换到该分支，可以在 **git switch** 命令后面加上 **-c** 或 **--create** 选项，然后指定分支名称。

以下命令用于创建一个新分支 **<new-branch-name>** 并立即切换到新创建的分支:

```
git switch -c <new-branch-name>
```

例如创建一个名为 feature-branch 的新分支并切换到它:

```
git switch -c feature-branch
```

**切换到前一个分支**

以下命令可以让你快速切换回前一个分支，无需记住分支名称:

```
git switch -
```

**恢复工作目录到某个特定的提交状态**

```
git switch <commit_hash>
```



### git restore  恢复/撤销

**恢复工作区中的文件git restore**

恢复工作区中的文件到最近的提交状态（即丢弃对文件的所有未提交更改）：

```
git restore file.txt
```

**恢复暂存区中的文件**

将暂存区中的文件恢复到工作区，实际上是将文件从暂存区移除（不提交）：

```
git restore --staged file.txt
```

**从指定提交恢复文件**

从某个提交（例如 HEAD~1）中恢复文件：

```
git restore --source=HEAD~1 file.txt
```

**恢复文件的"我们"版本**

在合并冲突时，恢复为当前分支的版本（即"我们"的版本）：

```
git restore --ours file.txt
```

**恢复文件的"他们"版本**

在合并冲突时，恢复为另一个分支的版本（即"他们"的版本）：

```
git restore --theirs file.txt
```

**显示将要恢复的文件和路径**

显示将要恢复的文件和路径，而不实际进行恢复：

```
git restore --dry-run
```

**恢复多个文件**

恢复工作区中的多个文件：

```
git restore file1.txt file2.txt
```



### git log 查看日志及常用选项

```bash
git log -n <number>                        限制显示的提交数
git log -n 5                               显示最近的 5 次提交
git log --since="2024-01-01"               显示自指定日期之后的提交
git log --until="2024-07-01"               显示指定日期之前的提交
git log --author="Author Name"             只显示某个作者的提交
```



## 进阶操作

### 1、交互式暂存（Interactive Staging）

`git add` 命令可以选择性地将文件或文件的一部分添加到暂存区，这在处理复杂更改时非常有用。

- **使用 `git add -p`**：逐块选择要暂存的更改。

```
git add -p
```

执行此命令后，Git 会逐块显示文件的更改，你可以选择是否暂存每个块。常用选项包括：

- `y`：暂存当前块
- `n`：跳过当前块
- `s`：拆分当前块
- `e`：手动编辑当前块
- `q`：退出暂存

### 2、Git Stash：临时保存工作进度

`git stash` 命令允许你临时保存当前工作目录的更改，以便你可以切换到其他分支或处理其他任务。

```bash
git stash                      //保存当前工作进度
git stash list                //查看存储的进度
git stash apply               // 应用最近一次存储的进度
git stash pop                // 应用并删除最近一次存储的进度
git stash drop stash@{n}    //  删除特定存储
git stash clear             //清空所有存储
```

### 3、Git Rebase：变基

`git rebase` 命令用于将一个分支上的更改移到另一个分支之上。它可以帮助保持提交历史的线性，减少合并时的冲突。

变基当前分支到指定分支：

```
git rebase <branchname>
```

例如，将当前分支变基到 `main` 分支：

```
git rebase main
```

- **交互式变基**：

```
git rebase -i <commit>
```

交互式变基允许你在变基过程中编辑、删除或合并提交。常用选项包括：

- `pick`：保留提交
- `reword`：修改提交信息
- `edit`：编辑提交
- `squash`：将当前提交与前一个提交合并
- `fixup`：将当前提交与前一个提交合并，不保留提交信息
- `drop`：删除提交

### 4、Git Cherry-Pick：拣选提交

`git cherry-pick` 命令允许你选择特定的提交并将其应用到当前分支。它在需要从一个分支移植特定更改到另一个分支时非常有用。

**拣选提交**：

```
git cherry-pick <commit>
```

例如，将 `abc123` 提交应用到当前分支：

```
git cherry-pick abc123
```

**处理拣选冲突**：如果拣选过程中出现冲突，解决冲突后使用 `git cherry-pick --continue` 继续拣选。





### 示例操作

以下是一个综合示例，展示了如何使用这些进阶操作：

**交互式暂存**：

```
git add -p
```

**保存工作进度**：

```
git stash
```

**查看存储的进度**：

```
git stash list
```

**应用存储的进度**：

```
git stash apply
```

**变基当前分支到 `main` 分支**：

```
git rebase main
```

**交互式变基，编辑提交历史**：

```
git rebase -i HEAD~3
```

编辑提交历史，如合并和重命名提交。

**拣选 `feature` 分支上的特定提交到 `main` 分支**：

```
git checkout main
git cherry-pick abc123
```