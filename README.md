# imguitls

## principle

1. build feature image
2. build base image (by bind feature images)

```Dockerfile
FROM centos:7

# ::feature:: hello@v1.0
RUN --mount=type=bind,from=seanly/imgutils:feature-hello-v1.0,source=/src,target=/tmp/build-feature-src \
    cp -ar /tmp/build-feature-src /tmp/imgutils-build-feature \
    && chmod -R 0755 /tmp/imgutils-build-feature \
    && cd /tmp/imgutils-build-feature \
    && chmod +x ./install.sh \
    && ./install.sh \
    && rm -rf /tmp/imgutils-build-feature

# ::feature:: hello@v1.0 { hello: 'hi, world' }
FROM centos:7 as feature_hello_v1.0
COPY --from=seanly/imgutils:feature-hello-v1.0 /src /tmp/build-feature-src
RUN set -eux \
    ;echo "export __FEATURE_HELLO_HELLO__='hi, world'" >> /tmp/build-feature-src/.feature.buildins.env

FROM centos:7
RUN --mount=type=bind,from=feature_hello_v1.0,source=/tmp/build-feature-src,target=/tmp/build-feature-src \
    cp -ar /tmp/build-feature-src /tmp/imgutils-build-feature \
    && chmod -R 0755 /tmp/imgutils-build-feature \
    && cd /tmp/imgutils-build-feature \
    ; cat /tmp/imgutils-build-feature/.feature.buildins.env \
    ; source /tmp/imgutils-build-feature/.feature.buildins.env \
    ; chmod +x ./install.sh \
    ; cat ./install.sh \
    ; ./install.sh \
    ; rm -rf /tmp/imgutils-build-feature

```

## usage

```bash
cd base
bash bind-features.sh  < base/rockylinux9/Dockerfile > Dockerfile.features
# or
bash bind-features.sh --bind-feature=base@v1.0 < base/rockylinux9/Dockerfile > Dockerfile.features
```
