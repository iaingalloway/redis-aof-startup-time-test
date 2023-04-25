# Redis AOF Startup Time Test

A basic load test to measure how the size of the AOF affects the startup time of Redis.

## Prerequisites

- Docker and Docker Compose (e.g. Docker Desktop)

## Setup

Run the load test using the following script:

```bash
./run-test.sh
```

You can customize the parameters by passing arguments to the script:

```bash
./run-tests.sh -k 4000000
```

This will run the test creating 4,000,000 1KB keys, for a total AOF size of around 4GB.

## Results

On my machine, I get the following results

| AOF Size | Startup Time |
| -------- | ------------ |
| 1GB      |  2.5s        |
| 2GB      |  5s          |
| 4GB      | 10s          |
