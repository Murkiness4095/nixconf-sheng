# NixOS 声明式配置 —— 快捷命令（sheng / Xiaomi Pad 6S Pro, aarch64-linux）
#
# 用法：
#   just              # 列出全部命令
#   just eval         # 求值验证（x86 开发机也能跑，不构建 aarch64 产物）
#   just os           # 构建并激活系统（在平板上执行，最常用）
#
# 本仓库目标平台是 aarch64-linux：开发机（x86_64）没有 binfmt/qemu、也没有
# remote builder，只能求值，不能构建。真正的构建/激活/切换只在平板本地做。
# 所有 recipe 都以仓库根目录为工作目录（just 默认行为）。

host := "sheng"
user := "fall_dust"

# ────────────────────────────── 系统（在平板上执行） ──────────────────────────────

# 构建并激活系统配置（等价于 nixos-rebuild switch）
os *args:
    nh os switch -H {{host}} . {{ if args == "" { "" } else { "-- " + args } }}

# 仅构建，不激活、不改动启动项
build *args:
    nh os build -H {{host}} . {{ if args == "" { "" } else { "-- " + args } }}

# 构建并设为下次开机默认配置
boot *args:
    nh os boot -H {{host}} . {{ if args == "" { "" } else { "-- " + args } }}

# 临时激活新配置，重启后自动回滚（适合验证有风险的改动）
test *args:
    nh os test -H {{host}} . {{ if args == "" { "" } else { "-- " + args } }}

# 空跑：打印将要执行的动作，不做任何改动
dry:
    nh os switch -H {{host}} . --dry

# 回滚到上一个 generation
rollback:
    nh os rollback

# 列出系统的 generation 历史
gens:
    nh os info

# 对比当前 generation 与上一次的闭包差异
diff:
    #!/usr/bin/env bash
    set -euo pipefail

    mapfile -t gens < <(ls -1dv /nix/var/nix/profiles/system-*-link 2>/dev/null || true)

    if [ "${#gens[@]}" -lt 2 ]; then
        echo "只有一个 generation，无可对比对象"
        exit 0
    fi

    nvd diff "${gens[-2]}" /run/current-system

# ────────────────────────────── 验证（x86 开发机可跑） ──────────────────────────────

# 求值验证：系统 drvPath + hjem 用户包列表
eval:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "== system toplevel drvPath"
    nix eval --raw .#nixosConfigurations.{{host}}.config.system.build.toplevel.drvPath
    echo

    echo "== hjem packages"
    nix eval --raw .#nixosConfigurations.{{host}}.config.hjem.users.{{user}}.packages \
        --apply 'l: "${toString (builtins.length l)} 个：${builtins.concatStringsSep " " (map (p: p.name) l)}"'
    echo

# 校验 flake 全部输出与模块求值（会构建 aarch64 产物，x86 上请改用 just eval）
check *args:
    nix flake check {{ if args == "" { "" } else { args } }}

# 打印 flake 的输出（packages / nixosConfigurations 等）
show:
    nix flake show

# ────────────────────────────── flake 与维护 ──────────────────────────────

# 更新 flake input：just up nixpkgs / just up（lock 动得越多，设备端要现场构建的包越多）
up *args:
    nix flake update {{ args }}

# 格式化仓库内全部 .nix 文件（nixfmt，RFC 风格）
fmt:
    #!/usr/bin/env bash
    set -euo pipefail

    mapfile -t files < <(git ls-files -co --exclude-standard '*.nix')

    if [ "${#files[@]}" -eq 0 ]; then
        echo "没有找到 .nix 文件"
        exit 0
    fi

    nixfmt "${files[@]}"
    echo "已格式化 ${#files[@]} 个文件"

# 仅检查格式是否合规，不修改文件
fmt-check:
    #!/usr/bin/env bash
    set -euo pipefail

    mapfile -t files < <(git ls-files -co --exclude-standard '*.nix')
    nixfmt --check "${files[@]}"

# 手动清理 30 天前的旧 generation 与无引用 store 路径（sheng 上自动 GC 是刻意关掉的）
gc:
    # rootfs 一旦带 ext4 错误启动，开机补跑 GC 容易把 /nix/store 写入压力放大成
    # emergency read-only，所以这里只在需要时手动执行。
    sudo nix-collect-garbage --delete-older-than 30d

# 列出全部快捷命令
default:
    @just --list
