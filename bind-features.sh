#!/bin/bash

new_dockerfile=""

# 解析命令行参数
parse_command_line_args() {
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --bind-feature=*)
        bind_feature "${key#*=}"
        ;;
      --debug)
        set -x
        ;;
      *)
        # 无法识别的参数，忽略
        ;;
    esac
    shift
  done
}

# 处理特性绑定
bind_feature() {
  feature="${1}"
  feature_name="${feature%%@*}"
  version="${feature#*@}"
  version="${version:-latest}"
  bind_command="RUN --mount=type=bind,from=seanly/feature-images:features-$feature_name-$version,source=/src,target=/tmp/feature-src \\
    cp -ar /tmp/feature-src /tmp/build-src; chmod -R 0755 /tmp/build-src \\
    && cd /tmp/build-src; chmod +x ./install.sh \\
    ;echo 'export __FEATURE_PATH__=/tmp/build-src' >> /tmp/build-src/.feature.buildins.env \\
    ;source /tmp/build-src/.feature.buildins.env; ./install.sh \\
    && rm -rf /tmp/build-src
    "
  # 将 bind 命令添加到新的 Dockerfile
  new_dockerfile+="\n$bind_command"
}

# 处理标准输入
process_input() {
  while IFS= read -r line; do
    if [[ "$line" =~ ^\s*"# ::feature:: " ]]; then
      parse_feature_line "$line"
    else
      new_dockerfile+="$line"
    fi
    new_dockerfile+="\n"
  done
}

# 解析特性行
parse_feature_line() {
  line="$1"
  regex="# ::feature:: ([^@]+)(@([^ ]+)(.*))?"
  if [[ "$line" =~ $regex ]]; then
    feature_name="${BASH_REMATCH[1]}"
    version="${BASH_REMATCH[3]:-latest}"
    remaining_content="${BASH_REMATCH[4]}"
    bind_feature "seanly/feature-images:features-$feature_name-$version"
    new_dockerfile+="$remaining_content"
  else
    new_dockerfile+="$line"
  fi
}

# 重构后的脚本入口
main() {
  process_input
  parse_command_line_args "$@"
  echo -e "$new_dockerfile"
}

main "$@"
