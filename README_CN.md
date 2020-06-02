# vinegar.vim

> Split windows and the project drawer go together like oil and vinegar. I
> don't mean to say that you can combine them to create a delicious salad
> dressing. I mean that they don't mix well!
> - Drew Neil

你大概知道 Vim 里的 netrw 吧?  这是一个内置的文件浏览器。
vinegar.vim 就是用来强化 netrw 的插件。
它尝试缓和多窗口与破坏性的 ["project drawer"][Oil and vinegar] 抽屉式项目菜单风格的插件间的冲突。

[Oil and vinegar]: http://vimcasts.org/blog/2013/01/oil-and-vinegar-split-windows-and-project-drawer/ 水火不容

vinegar.vim 的一些行为会是内置 netrw 的一个极佳的补充。
很多插件的作者可能会拒绝评论，更多的人可能连想都没想过。

## 按键设定

* 在任意缓冲区按下 `-` 从当前文件跳转到所在的目录列表。
  继续按就一直往上。开挂一样快速的目录访问。

* netrw 的顶部无关紧要的信息被关闭了, 留给你的除了软件列表再无其他。
  你可能会陷入一时迷茫, 但最终你会得到解放。
  如果你还是更习惯 netrw，那就按 `I` 来切换。
  
* 合理应用 `'suffixes'` （后缀）改变奇怪的 C 风格的默认排序
  
* 隐藏文件: 如果你设置了 `'wildignore'` 那么这些文件就会不可见。 
  如果你在你的 vimrc 里写了 `let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'`，
  vinegar 就会隐藏这些以点号开头的文件。
  按下 `gh` 切换显示。
  
* 按下 `.` 把当前光标下的文件输入到命令模式`:` 的结尾。
  这是一个很好的实践, 比如说, 你想针对当前光标下的文件或文件夹快速启动 `:grep` 
  `!` 同理。
  输入 `!chmod +x` 你得到的是 `:!chmod +x path/to/file`。

* 按下 `y.` 复制光标下文件的绝对路径。
* 按下 `~` 回到 `$HOME` 主目录。
* 使用 Vim 内置的 `CTRL-^` (`CTRL-6`) 从 netrw 缓冲区切换到之前的缓冲区。

## 安装

用任何你喜欢的插件管理器安装, 或者用 Vim 内置的插件管理器（搭配 Git）:

```shell
    mkdir -p ~/.vim/pack/tpope/start
    cd ~/.vim/pack/tpope/start
    git clone https://github.com/tpope/vim-vinegar.git
```

## 贡献

喜欢 vinegar.vim?  
在 [GitHub](https://github.com/tpope/vim-vinegar)  上收藏它！
你还可以在 [vim.org](https://www.vim.org/scripts/script.php?script_id=5671) 上投出你宝贵的一票！

爱上 vinegar.vim?  
在 [GitHub](https://github.com/tpope) 和 [Twitter](http://twitter.com/tpope) 上关注 [tpope](http://tpo.pe/) 
。

## License

Copyright © Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
