# Builder Stage
FROM alpine:edge as builder

# Install necessary packages using apk add
RUN apk update && apk add \
    cmake \
    g++ \
    curl \
    unzip \
    git \
    libtbb-dev \
    make \
    linux-headers

# Working directory setup
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/dhbloo/rapfi.git .

# Build process
RUN cd Rapfi \
    && mkdir build  \
    && cd build  \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make

# Final Stage
FROM alpine:edge
LABEL author="xanonymous"

# Copy necessary files from builder stage
COPY --from=builder /app/Rapfi/build/pbrain-rapfi /app/rapfi

# Install necessary packages using apk add
RUN apk update && apk add --no-cache \
    libtbb-dev \
    linux-headers

# Set default command to execute
CMD ["/app/rapfi"]
