FROM golang:1.20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the source files to the container
COPY main.go .

# Initialize Go modules
RUN go mod init myapp && go mod tidy

# Build the binary
RUN go build -o myapp .

# Expose the port that the container listens on
EXPOSE 8080

# Start the binary when the container starts
CMD ["./myapp"]
