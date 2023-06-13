# feature-images

## principle

1. build feature image
2. build base image (by bind feature images)

```Dockerfile
FROM centos:7

# ::feature:: hello@v1.0
RUN --mount=type=bind,from=seanly/feature-images:features-hello-v1.0,source=/src,target=/tmp/feature-src \
    cp -ar /tmp/feature-src /tmp/build-src \
    && chmod -R 0755 /tmp/build-src \
    && cd /tmp/build-src \
    && chmod +x ./install.sh \
    && ./install.sh \
    && rm -rf /tmp/build-src

# ::feature:: hello@v1.0 { hello: 'hi, world' }
FROM centos:7 as feature_hello_v1.0
COPY --from=seanly/feature-images:features-hello-v1.0 /src /tmp/feature-src
RUN set -eux \
    ;echo "export __FEATURE_HELLO_HELLO__='hi, world'" >> /tmp/feature-src/.feature.buildins.env

FROM centos:7
RUN --mount=type=bind,from=feature_hello_v1.0,source=/tmp/feature-src,target=/tmp/feature-src \
    cp -ar /tmp/feature-src /tmp/build-src \
    && chmod -R 0755 /tmp/build-src \
    && cd /tmp/build-src \
    ; cat /tmp/build-src/.feature.buildins.env \
    ; source /tmp/build-src/.feature.buildins.env \
    ; chmod +x ./install.sh \
    ; cat ./install.sh \
    ; ./install.sh \
    ; rm -rf /tmp/build-src

```

## usage

```bash
cd base
bash bind-features.sh  < base/rockylinux9/Dockerfile > Dockerfile.features
# or
bash bind-features.sh --bind-feature=base@v1.0 < base/rockylinux9/Dockerfile > Dockerfile.features
```
