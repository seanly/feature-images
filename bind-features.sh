#!/bin/bash
new_dockerfile=""

# 逐行处理标准输入
while IFS= read -r line; do
  if [[ "$line" =~ ^\s*"# ::feature:: " ]]; then
    # 匹配以 # ::feature:: 开头的注释行
    regex="# ::feature:: ([^@]+)(@([^ ]+)(.*))?"
    if [[ "$line" =~ $regex ]]; then
      # 获取匹配结果
      feature_name="${BASH_REMATCH[1]}"
      version="${BASH_REMATCH[3]:-latest}"
      remaining_content="${BASH_REMATCH[4]}"

      # 构建 RUN bind 命令
      bind_command="RUN --mount=type=bind,from=seanly/feature-images:features-$feature_name-$version,source=/src,target=/tmp/feature-src \\
      cp -ar /tmp/feature-src /tmp/build-src; chmod -R 0755 /tmp/build-src \\
      && cd /tmp/build-src; chmod +x ./install.sh \\
      ;echo 'export __FEATURE_PATH__=/tmp/build-src' >> /tmp/build-src/.feature.buildins.env \\
      ;source /tmp/build-src/.feature.buildins.env; ./install.sh \\
      && rm -rf /tmp/build-src
      "

      # 将注释行替换为 RUN bind 命令
      new_dockerfile+="$bind_command$remaining_content"
    else
      # 无法匹配的注释行，保留原始内容
      new_dockerfile+="$line"
    fi
  else
    # 非注释行，保留原始内容
    new_dockerfile+="$line"
  fi
  # 添加换行符
  new_dockerfile+="\n"
done

# 输出替换后的 Dockerfile
echo -e "$new_dockerfile"
