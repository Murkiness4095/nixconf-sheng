# Agent Git & Commit Rules

本仓库（sheng 平板 aarch64 设备侧 nix-config）所有提交必须遵循
[Conventional Commits v1.0.0](https://www.conventionalcommits.org/zh-hans/v1.0.0/) 规范。

## 工作流

1. 改动完成后，仅 `git add` 与当前任务直接相关的文件。
2. 提交前必须验证：本机是 x86_64，**不能**构建 aarch64 产物，最低要求是求值通过——
   `nix eval .#nixosConfigurations.sheng.config.system.build.toplevel.drvPath`；
   涉及 hjem 用户包时再跑
   `nix eval --json .#nixosConfigurations.sheng.config.hjem.users.fall_dust.packages`。
   真机验证只能在平板上做：`sudo nixos-rebuild switch --flake .#sheng`。
3. 提交信息必须严格符合下方格式；禁止临时提交、空提交或描述含糊的提交。
4. 不要主动 `git push`；除非用户明确要求。
5. 每次提交完成后，向用户报告提交 hash 与提交信息。

## 暂存与提交禁忌

- 不要使用 `git add .` 全量暂存；逐文件确认。
- 不要提交 `flake.lock.bak-*` 之类的备份、`result*` 符号链接、rootfs/boot 镜像（`.img`/`.zip`）、
  日志、临时目录、密钥明文。
- 不要执行 `--amend`、`reset`、`rebase -i`、`push -f`、`clean -f`、`checkout -f` 等危险操作。
- 不要创建普通提交前询问确认；但遇到可能破坏仓库的破坏性操作（删除密钥、回滚 `flake.lock`、
  改写已推送历史）必须告知用户。

## 提交信息格式

```text
<type>(<scope>): <description>

[可选的 body，说明改动动机与行为变更]

[可选的 footer，BREAKING CHANGE: 或 Closes/Fixes/Refs]
```

### 规则

- `type` 与 `scope` 全部小写。
- `description` 使用祈使句、小写开头、末尾不加句号，长度 ≤ 72 字符。
- 需要额外说明时写 body；body 每行 ≤ 100 字符。
- 破坏性变更在 `type(scope)!:` 加 `!`，或在 footer 中写 `BREAKING CHANGE: 说明`。
- 一次提交只做一件事；多件事拆分提交。

## Type 定义

| type       | 用途                                                     |
| ---------- | -------------------------------------------------------- |
| `feat`     | 新增模块、桌面组件、包、flake 输出                       |
| `fix`      | 修复求值/构建失败、设备端运行问题、缓存与网络导致的阻塞  |
| `refactor` | 重构：既不新增功能也不修复 bug 的结构/命名/整理          |
| `perf`     | 缩短 rootfs/rebuild 时间、减小闭包体积、降低启动开销     |
| `style`    | 仅格式调整、空行、注释、拼写修正（不影响行为）           |
| `docs`     | 文档、注释、AGENTS.md、help 文本                         |
| `test`     | 测试、验证脚本、测试数据                                 |
| `build`    | flake/inputs 版本、derivation、overlay、rootfs 构建产物  |
| `ci`       | CI/CD、GitHub Actions、自动化脚本                        |
| `chore`    | 仓库维护、git 配置、不影响主代码的杂项                   |

## Scope 定义

| scope      | 对应路径/内容                                                     |
| ---------- | ----------------------------------------------------------------- |
| `repo`     | 仓库级配置、git、AGENTS.md、`parts.nix` 之外的杂项                |
| `flake`    | `flake.nix`、`flake.lock`、`parts.nix`、inputs/outputs 结构       |
| `host`     | `configuration.nix`：`nixosConfigurations.sheng`、平台覆盖、字体、zram/swap、systemPackages |
| `user`     | `user.nix`、`ssh.nix`：账号、密码哈希、公钥                       |
| `core`     | `core/`：`core.nix`、`hjem.nix`、`pkgs.nix`、`shell/`、`fastfetch/` |
| `desktop`  | `niri/`、`noctalia/`、`fuzzel.nix`、`thunar.nix`、`theme.nix`、`power.nix` |
| `terminal` | `alacritty.nix`、`kitty.nix`                                      |
| `ime`      | `fcitx5.nix`、`ibus.nix`                                          |
| `programs` | `sheng-programs.nix`：hjem 用户软件集合                           |
| `packages` | `librewolf.nix`、`nixpak/`：自定义包与沙箱封装                    |
| `editor`   | `vscode/`、`zed/`                                                 |
| `assets`   | `assets/`：壁纸、logo 等静态资源                                  |

使用最具体的 scope；若改动跨多个 scope，应拆分提交；确实无法拆分时可省略 scope。

## 提交示例

```text
feat(programs): add brave-origin to hjem packages

fix(host): force sheng hostname and timezone over platform defaults

perf(programs): drop firefox to avoid building ffmpeg locally

build(flake): update nixos-sheng to feat/niri-noctalia-image

docs(repo): add agent git and commit rules

chore(repo): add .gitignore
```

## 提交报告

每次提交后向用户简要说明：

```text
已提交：<hash> <type>(<scope>): <description>
```
