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
# Run the service container (uses port 80 by default)
make run
```

## Endpoints
Endpoint | Method | Example `curl`
--- | --- | ---
`/health` | GET | `curl localhost/health`
`/get` | POST | `curl -XPOST localhost/get -d '{"hash": "123456"}'`
`/store` | POST | `curl -XPOST localhost/store -d '{"message":"hello"}'`

For example,
```bash
$ curl -XPOST localhost/get -d '{"hash":"123456"}'
{"message":"","found":false}

$ curl -XPOST localhost/store -d '{"message":"hello"}'
{"hash":"2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"}

$ curl -XPOST localhost/get -d '{"hash":"2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"}'
{"message":"hello","found":true}
```

## Push Image to ECR
The following command will push the hash-service image to ECR. It expects the following environment variables:
- `AWS_ACCOUNT_ID`
- `AWS_REGION`
- `PROJECT_NAME` (should match the terraform `project_name` variable)

```bash
AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID AWS_REGION=$AWS_REGION PROJECT_NAME=$PROJECT_NAME make push
```

## Storage
Messages are stored in-memory and will not be persisted.

## TODOs
- Build CI/CD pipeline for building and pushing the image
- Add git commit SHAs as image tags
