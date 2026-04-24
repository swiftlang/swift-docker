FROM amazonlinux:2023
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=amazonlinux2023
ARG SWIFT_WEBROOT=https://download.swift.org/development
ARG SWIFT_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM"

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_WEBROOT=$SWIFT_WEBROOT

RUN echo "${SWIFT_WEBROOT}/latest-build.yml"

RUN set -e; \
    ARCH_NAME="$(rpm --eval '%{_arch}')"; \
    case "${ARCH_NAME##*-}" in \
        'x86_64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'aarch64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    # - Bug: https://github.com/amazonlinux/amazon-linux-2023/issues/243
    dnf -y swap gnupg2-minimal gnupg2-full \
    && export $(curl -s ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g') \
    && export $(curl -s ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/latest-build.yml | grep 'download_signature:' | sed 's/:[^:\/\/]/=/g') \
    && export DOWNLOAD_DIR=$(echo $download | sed "s/-${SWIFT_PLATFORM}${OS_ARCH_SUFFIX}.tar.gz//g") \
    && echo $DOWNLOAD_DIR > .swift_tag \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && dnf -y install tar gzip \
    && curl -fsSL ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz \
    ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/${DOWNLOAD_DIR}/${download_signature} -o latest_toolchain.tar.gz.sig \
    && curl -fSsL --compressed https://swift.org/keys/all-keys.asc | gpg --import - \
    && gpg --batch --verify latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf latest_toolchain.tar.gz --directory / --strip-components=1 \
       ${DOWNLOAD_DIR}-${SWIFT_PLATFORM}${OS_ARCH_SUFFIX}/usr/lib/swift/linux \
       ${DOWNLOAD_DIR}-${SWIFT_PLATFORM}${OS_ARCH_SUFFIX}/usr/libexec/swift/linux \
    && chmod -R o+r /usr/lib/swift /usr/libexec/swift \
    && rm -rf "$GNUPGHOME" latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    && dnf autoremove -y tar gzip

RUN echo "[ -n \"\${TERM:-}\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bashrc; \
    ( \
      printf "################################################################\n"; \
      printf "# %-60s #\n" ""; \
      printf "# %-60s #\n" "Swift Nightly Docker Image"; \
      printf "# %-60s #\n" "Tag: $(cat .swift_tag)"; \
      printf "# %-60s #\n" ""; \
      printf "################################################################\n" \
    ) > /etc/motd

RUN echo 'source /etc/bashrc' >> /root/.bashrc
