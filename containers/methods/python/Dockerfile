FROM python:3.7-alpine

# use testing repo for hdf5
RUN echo "http://mirror1.hs-esslingen.de/pub/Mirrors/alpine/v3.8/main" >> /etc/apk/repositories; \
    echo "http://mirror1.hs-esslingen.de/pub/Mirrors/alpine/v3.8/community" >> /etc/apk/repositories; \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories; \
    echo "http://mirror1.hs-esslingen.de/pub/Mirrors/alpine/edge/testing" >> /etc/apk/repositories

# create virtual package for sklearn-runtime, install build-dependencics and remove after compilation.
# for matplotlib add: freetype-dev libpng-dev tcl tk
COPY ./requirements.txt /requirements/
RUN apk add --no-cache --virtual sklearn-runtime python3 git bash zlib hdf5 libgfortran libgcc libstdc++ musl openblas && \
    apk add --no-cache --virtual .build-deps build-base python3-dev zlib-dev hdf5-dev freetype-dev libpng-dev openblas-dev && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    pip3 install --no-cache-dir "numpy==1.15.3" && \
    pip3 install --no-cache-dir -r /requirements/requirements.txt && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/*

COPY main.py /code/

ENTRYPOINT ["/code/main.py"]
