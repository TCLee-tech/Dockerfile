# Dockerfile for python 3.13 on Debian/Ubuntu bookworm-slim
*** for running Streamlit OpenAI FastAPI ***
#### The Dockerfile is annotated for easy reading. Comments on best practices incorporated below:

## Features:

- [Debian/Ubuntu bookworm slim base image](https://hub.docker.com/layers/library/python/3.13.1-slim-bookworm/images/sha256-c5aba0b4da73e67be91c7b4a413d7fbb04d20c13a9fce4706adf6ec69bcc7bb6?context=explore) => smaller image size, faster build
- multi-stage build
  - discard build tools in final stage
  - smaller final image size
- optimized order of comamnds
  - fewer layers to cache => faster build
  - application code copied into container near end of build process. No effect on prior steps for changes made only to application code during development.
- combined RUN, COPY and ADD commands since they add layers
- option to remove Jupyter Notebook files if you are not using container for data science
- virtualenv for isolation
- non-root user (least privilege principle)
  - container meant for end user. No write permission. No shell access.
- healthcheck for working (not just running) container
- no secrets stored in code, in environment, during build-time, in build history. No logs.

### Notes:
- Alpine Linux's base image is very small. However,
  - it uses some different components, e.g. musl libc instead of glibc
  - Size is small because many dependencies needed to build Streamlit and python modules are absent. Downloading takes time and adds bloat.
  - risk of breaking when running or updating/changing libraries during development.

### Recommendations:
- tag images properly
- set memory and CPU limits
- secure network for running container
