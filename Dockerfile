FROM golang:latest AS builder

WORKDIR /app

COPY . .
RUN go build -o myapp ./hello

FROM alpine:latest
WORKDIR /root/

COPY --from=builder /app/myapp .

CMD ["./myapp"]