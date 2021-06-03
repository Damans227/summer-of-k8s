FROM golang:1.12.0 
RUN mkdir /app
ADD . /app
WORKDIR /app
RUN go build -o main .
EXPOSE 8081
CMD ["go", "run", "hello-world.go"]
