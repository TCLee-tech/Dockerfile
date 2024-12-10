# https://testdriven.io/blog/docker-best-practices/#use-multi-stage-builds
# initialize new build stage
FROM python:3.13.1-slim-bookworm AS compiler

# stops Python from writing pyc files and buffering stdin/stdout
ENV PYTHONWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# set working directory in container. / is  root of file system in container.
WORKDIR /market_news

# To remove Jupyter Notebook files, uncheck block below
# no significant size reduction but may remove CVE risks
#RUN apt-get update && apt-get remove --purge -y jupyter-notebook \
#    && apt-get autoremove -y \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/*

# install necessary build tools then clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
# install virtualenv and create a virtual environment
# why virtualenv instead of venv: https://virtualenv.pypa.io/en/latest/
    && pip3 install virtualenv \
    && virtualenv /.venv
    
# activate and use virtual environment
ENV PATH="/.venv/bin:$PATH"

# Copy requirements.txt into container's working dir
COPY requirements.txt .

# install packages, using pip in virtual (not global) environment
RUN pip3 install --no-cache-dir -r requirements.txt


# final build stage
FROM python:3.13.1-slim-bookworm AS final

# arguments for creating a non-root user
ARG USERNAME=non-root-username-goes-here
ARG USER_UID=1001
ARG USER_GID=${USER_UID}

# create non-root user with no shell access and no home directory
# for alpine, it is adduser and addgroup
RUN groupadd --gid=${USER_GID} --system ${USERNAME} \
    && useradd --no-create-home --shell=/bin/false --no-log-init \
    --uid=${USER_UID} --gid=${USER_GID} --system ${USERNAME}

# set the working directory
WORKDIR /market_news

# activate virtual environment in final stage
ENV PATH="/.venv/bin:$PATH"

# copy virtual environment from builder stage into virtual environment in final stage
COPY --from=compiler /.venv /.venv

# copy application code
COPY . .

# chown - change ownership of /market_news directory to new non-root user
# set directory's permission to read and execute only (555), ensure the non-root user cannot modify the application's code
RUN chown -R ${USER_UID}:${USER_GID} /market_news \
    && chmod -R 555 /market_news

# Set user to non-root user
USER ${USERNAME}

# expose Streamlit's default port
EXPOSE 8501

# test if container is working. 1 is for unhealthy status, so exit if unhealthy.
HEALTHCHECK CMD ["curl", "--fail", "http://localhost:8501/_stcore/health", "||", "exit", "1"]

ENTRYPOINT ["/.venv/bin/streamlit", "run", "project.py", "--server.port=8501"]

# To execute:
# docker build -t [image-name] .
# Either:
# docker run -d -p 8501:8501 --name=[container-name] [image-name]
# -d runs container in detached mode (in background)
# -p 8501:8501 is to map port 8501 on host to port 8501 in container
# Or:
# streamlit run project.py