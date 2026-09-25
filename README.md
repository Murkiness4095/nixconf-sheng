# nixconf-sheng —— 小米平板 6S Pro 的设备侧 NixOS 配置

针对**专用设备**的 nix 配置：小米平板 6S Pro（代号 `sheng`，`aarch64-linux`）。
它不是通用桌面配置——硬件平台（内核、DTB、固件、stage-1、传感器、触控、指纹、
音频等）由 [nixos-sheng](https://github.com/Murkiness4095/nixos-sheng) 的
`mkShengSystem` 提供，本仓库只负责账号、凭据、桌面会话、主题与个人软件。

## 结构：flake-parts，一个文件一个模块

整仓用 [flake-parts](https://github.com/hercules-ci/flake-parts) 组织：**每个 `.nix`
文件本身就是一个 flake-parts 模块**，按功能切分；`flake.nix` 用 `lib.fileset`
递归 import 除 `flake.nix` 和 `_` 前缀之外的所有 `.nix` 文件。因此新增一个功能模块
= 新增一个文件，不需要维护 import 列表，也不会出现“忘了注册模块”的情况。

- `hosts/`：宿主入口 —— 系统装配与平台默认值覆盖。
- `features/`：功能模块 —— 桌面会话、终端、输入法、编辑器、主题、用户软件集合等；
  `features/base/` 是账号身份与 SSH 的统一入口，`features/extra/` 放 hjem 接线这类
  粘合模块。
- `wrappedPrograms/`：需要额外封装的程序 —— LibreWolf 与 qq/wechat 沙箱。
- `assets/`：壁纸与 logo。

`flake.nix`、`Justfile` 等仓库级文件留在仓库根。

用户级配置与软件由 [hjem](https://github.com/feel-co/hjem) 管理，替代 home-manager。

## 用法

```sh
just            # 列出全部命令
just eval       # 求值验证：系统 drvPath + hjem 包列表（x86 开发机也能跑）
just os         # 构建并激活系统（在平板上执行）
```

平板上也可以直接用原生命令：

```sh
sudo nixos-rebuild switch --flake .#sheng
```

`just` 的 `os`/`build`/`boot`/`test` 走 `nh os -H sheng`，依赖 `nh`（已在
`features/programs.nix` 中安装）；`diff` 依赖 `nvd`。

## 两条硬约束

1. **目标平台是 `aarch64-linux`**：开发机（x86_64）没有 binfmt/qemu、也没有 remote
   builder，只能求值、不能构建；真正的构建与激活只在平板本地做。`just eval` 就是给
   开发机准备的验证入口。
2. **设备端 rebuild 只能 substitute 或复用设备 store**：不在 binary cache
   （`cache.nixos.org`、`nixos-sheng.cachix.org`）里的包必须在平板上现场构建，而源托管在
   `github.com` 的包（例如 Brave 的 `.deb`）在平板网络下下不动，rebuild 会卡在下载阶段。
   加新包前先确认缓存里有：`nix path-info --store https://cache.nixos.org <outPath>`。

另外：内核、DTS、stage-1 initrd 属于 `boot_b`，`nixos-rebuild` 不会覆盖，改动这些要重新
构建并刷镜像。`flake.lock` 与刷入平板的 rootfs 保持对齐（`nixos-sheng` 的 `niri` 分支），
不要随手整体更新。

## License

[MIT](LICENSE)
