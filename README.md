# Dockerfile for python 3.13 on Debian/Ubuntu bookworm-slim
*** for running Streamlit OpenAI FastAPI ***
#### The Dockerfile is annotated for easy reading. Comments on best practices incorporated below:

## Features:
- container for application serving end-users
- [Debian/Ubuntu bookworm slim base image](https://hub.docker.com/layers/library/python/3.13.1-slim-bookworm/images/sha256-c5aba0b4da73e67be91c7b4a413d7fbb04d20c13a9fce4706adf6ec69bcc7bb6?context=explore) => smaller image size, faster build
- multi-stage build
  - discard build tools in final stage
  - nearly 50% smaller image size compared to standard build
- optimized order of comamnds
  - fewer layers to cache => faster build
  - application code copied into container near end of build process. No effect on prior steps for changes made only to application code during development.
- combined RUN, COPY and ADD commands since they add layers
- option to remove Jupyter Notebook files if you are not using container for data science
- virtualenv for isolation
- non-root user (least privilege principle)
  - container to run application meant for end user. No write permission. No shell access.
- healthcheck for working (not just running) container
- no secrets stored in code, in environment, during build-time, in build history, in secrets manager. No logs.

### Notes:
- Alpine Linux's base image is very small. However,
  - it uses some different components, e.g. musl libc instead of glibc
  - Size is small because many dependencies are absent. Downloading takes time and adds bloat.
  - risk of breaking when running or updating/changing libraries during development.

### Recommendations:
- tag images properly
- set memory and CPU limits
- secure network for running container

### Some compatible python package versions:
- [streamlit 1.41.1](https://pypi.org/project/streamlit/)
- [fastapi 0.115.6](https://pypi.org/project/fastapi/)
- [openai 1.58.1](https://pypi.org/project/openai/)
- [pytest 8.3.4](https://pypi.org/project/pytest/)
- [pytest-mock 3.14.0](https://pypi.org/project/pytest-mock/)
- [pytest-asyncio 0.25.0](https://pypi.org/project/pytest-asyncio/)
- [pydantic 2.10.4](https://pypi.org/project/pydantic/)
- [numpy 2.2.1](https://pypi.org/project/numpy/)
- [pandas 2.2.3](https://pypi.org/project/pandas/)
