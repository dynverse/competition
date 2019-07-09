FROM python:3.7

RUN apt-get update && apt-get install -y libhdf5-dev

COPY ./requirements.txt /requirements/

RUN pip3 install --no-cache-dir -r /requirements/requirements.txt

COPY main.py runner.sh /code/

RUN chmod +x /code/*

ENTRYPOINT ["/code/runner.sh"]
