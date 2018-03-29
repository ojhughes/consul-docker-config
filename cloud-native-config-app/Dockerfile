FROM library/golang:1.10-alpine
MAINTAINER Ollie Hughes <ohughes@pivotal.io>
RUN mkdir -p /go/src/app
ADD . /go/src/app
WORKDIR /go/src/app
RUN go build -o main .
CMD ["/go/src/app/main"]
