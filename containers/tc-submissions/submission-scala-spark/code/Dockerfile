FROM dynverse/spark:latest

COPY build.sbt /app/build.sbt
COPY Main.scala /app/src/main/scala/Main.scala

# Build package
RUN cd /app && sbt package
