# smtc_analytics_common_xeon_gst

FROM centos:7 as build

ARG VA_SERVING_REPO=https://github.com/intel/video-analytics-serving
ARG VA_SERVING_VERSION=0.6.1-beta
ARG VA_SERVING_TAG=v${VA_SERVING_VERSION}

ADD ${VA_SERVING_REPO}/archive/refs/tags/${VA_SERVING_TAG}.tar.gz /tmp
RUN mkdir -p /home/vaserving \
    && tar -xzf /tmp/${VA_SERVING_TAG}.tar.gz --strip-components=1 -C /home video-analytics-serving-${VA_SERVING_VERSION}/vaserving

COPY *.py /home/

FROM openvisualcloud/xeon-ubuntu1804-analytics-gst:21.6.1

RUN  apt-get update -qq && apt-get install -qq python3-gst-1.0 python3-jsonschema python3-psutil libgstrtspserver-1.0-dev && rm -rf /var/lib/apt/lists/*

COPY --from=build /home/ /home/
ENV  FRAMEWORK=gstreamer
ENV  PYTHONIOENCODING=UTF-8
ENV  PYTHONPATH=$PYTHONPATH:/home/vaserving

####
ARG  USER=docker
ARG  GROUP=docker
ARG  UID
ARG  GID
## must use ; here to ignore user exist status code
RUN  [ ${GID} -gt 0 ] && groupadd -f -g ${GID} ${GROUP}; \
     [ ${UID} -gt 0 ] && useradd -d /home -M -g ${GID} -K UID_MAX=${UID} -K UID_MIN=${UID} ${USER}; \
     chown -R ${UID}:${GID} /home
####

