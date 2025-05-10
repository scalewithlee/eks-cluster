# hash-service

An HTTP service that implements the following RESTful API:
- Take as input a string message. Store the message and return its SHA256 hash.
- Take as input a SHA256 hash. If that message has been previously stored, return the message associated with the hash.

## Development
Use the following `make` commands to build and run the service on your local machine using Docker:

```bash
# Build the service image
make build
```

```bash
# Run the service container (uses port 8080 by default)
make run
```

## Testing

```bash
make test
```

## Storage
Messages are stored in-memory and will not be persisted.
