FROM python:3.12-alpine

# Install build deps + runtime deps together
RUN apk add --no-cache \
        git \
        libffi-dev \
        musl-dev \
        gcc \
        g++ \
        leveldb-dev \
        make \
        zlib-dev \
        tiff-dev \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        lcms2-dev \
        libwebp-dev \
        openssl-dev \
        cargo \
        fastfetch \
        libstdc++ \
        snappy

# Set up venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install bot
RUN mkdir -p /src
WORKDIR /src
COPY . .
RUN pip install wheel && pip install .[fast] && pip install uvloop

# Clean up build deps (keep runtime ones)
RUN apk del gcc g++ musl-dev make cargo \
        zlib-dev tiff-dev freetype-dev libpng-dev \
        libjpeg-turbo-dev lcms2-dev libwebp-dev openssl-dev \
        libffi-dev leveldb-dev && \
    rm -rf /src /root/.cache /root/.cargo

# Re-add runtime libs that were pulled as deps of -dev packages
RUN apk add --no-cache \
        libffi leveldb libstdc++ snappy \
        zlib tiff freetype libpng libjpeg-turbo lcms2 libwebp

# Create bot user and data dir
RUN adduser -D pyrobud && mkdir -p /data && chown pyrobud:pyrobud /data
VOLUME ["/data"]

USER pyrobud
WORKDIR /data
CMD ["pyrobud"]
