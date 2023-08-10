# Builder Stage
FROM alpine:edge as builder

# Install necessary packages using apk add
RUN apk update && apk add \
    cmake \
    g++ \
    git \
    libtbb-dev \
    make \
    linux-headers

# Working directory setup
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/dhbloo/rapfi.git . \
    && git submodule update --init --recursive --force && git submodule sync

# Build process
RUN cd Rapfi \
    && mkdir build  \
    && cd build  \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make

# Final Stage
FROM alpine:edge
LABEL author="xanonymous"

# Install necessary packages using apk add
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
    openssl \
    libtbb

RUN addgroup -S rapfi \
    && adduser -S rapfi -G rapfi \
    --no-create-home \
    --shell /bin/false \
    --disabled-password

USER rapfi

# Working directory setup
WORKDIR /app

# Copy necessary files from builder stage
COPY --from=builder /app/Rapfi/build/pbrain-rapfi /app/rapfi
COPY --from=builder /app/Networks/mix7nnue /app
COPY --from=builder /app/Networks/classical /app
COPY ./config.toml /app/config.toml

# Set default command to execute
CMD ["/app/rapfi"]
