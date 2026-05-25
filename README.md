# StartTech Application

Full-stack todo application with a React frontend and Go backend API.

---

## Live URLs

| Service | URL |
|---|---|
| Frontend | https://d1nhyre8kou1dm.cloudfront.net |
| Backend API | http://starttech-alb-1944874729.eu-west-1.elb.amazonaws.com |
| Health Check | http://starttech-alb-1944874729.eu-west-1.elb.amazonaws.com/health |

---

## Architecture

```text
User → CloudFront (CDN) → S3 (React app)
User → ALB → EC2 Auto Scaling Group → Go API
                                → MongoDB Atlas
                                → ElastiCache Redis
```

---

## Repository Structure

```text
starttech-application/
├── .github/workflows/
│   ├── frontend-ci-cd.yml     # Build and deploy React to S3 + CloudFront
│   └── backend-ci-cd.yml      # Build Docker image, push to ECR, deploy to EC2
├── frontend/                  # React + Vite + TypeScript application
├── backend/                   # Go API with Gin framework
│   ├── cmd/api/               # Application entry point
│   ├── internal/
│   │   ├── handlers/          # HTTP handlers including /health
│   │   ├── routes/            # Route definitions
│   │   ├── middleware/        # Auth and other middleware
│   │   ├── models/            # Data models
│   │   ├── database/          # MongoDB connection
│   │   ├── cache/             # Redis connection
│   │   └── auth/              # JWT authentication
│   ├── Dockerfile             # Multi-stage Docker build
│   └── go.mod                 # Go module dependencies
├── scripts/
│   ├── deploy-frontend.sh     # Manual frontend deploy
│   ├── deploy-backend.sh      # Manual backend deploy
│   ├── health-check.sh        # Check backend health
│   └── rollback.sh            # Roll back to previous image
└── README.md
```

---

## CI/CD Pipelines

### Frontend Pipeline

Triggers on any push to the `main` branch that changes files inside the `frontend/` directory.

### Pipeline Steps

1. Install Node.js dependencies
2. Run tests
3. Run security audit
4. Build production bundle

```bash
npm run build
```

Build output is generated in:

```text
dist/
```

5. Sync `dist/` to S3
6. Invalidate CloudFront cache

---

### Backend Pipeline

Triggers on any push to the `main` branch that changes files inside the `backend/` directory.

### Pipeline Steps

1. Run Go tests

```bash
go test ./...
```

2. Run static analysis

```bash
go vet
```

3. Build Docker image
4. Push image to ECR using commit SHA tag
5. Scan image using Trivy
6. Rolling deploy to all EC2 instances via AWS Systems Manager (SSM)
7. Perform health check against the Application Load Balancer

---

## Local Development

### Backend

```bash
cd backend

export MONGO_URI="your-mongodb-uri"
export REDIS_HOST="localhost"
export APP_ENV="development"

go run cmd/api/main.go
```

Backend runs by default on:

```text
http://localhost:8080
```

---

### Frontend

```bash
cd frontend

export VITE_API_URL="http://localhost:8080"

npm install
npm run dev
```

Frontend development server starts locally using Vite.

---

### Run Backend Tests

```bash
cd backend
go test ./... -v
```

---

## Environment Variables

### Backend Variables

| Variable | Description | Required |
|---|---|---|
| `MONGO_URI` | MongoDB Atlas connection string | Yes |
| `REDIS_HOST` | Redis hostname | Yes |
| `REDIS_PORT` | Redis port (default: `6379`) | No |
| `APP_ENV` | Environment name | No |
| `PORT` | Server port (default: `8080`) | No |

---

### Frontend Variables

| Variable | Description |
|---|---|
| `VITE_API_URL` | Backend API base URL |

---

## Required GitHub Secrets

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | AWS region (`eu-west-1`) |
| `S3_BUCKET_NAME` | Frontend S3 bucket name |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID |
| `CLOUDFRONT_DOMAIN` | CloudFront domain name |
| `ECR_REPOSITORY_URL` | ECR repository URI |
| `MONGO_URI` | MongoDB Atlas connection string |
| `REDIS_HOST` | ElastiCache Redis endpoint |
| `ALB_DNS_NAME` | ALB DNS name (without `http://`) |
| `API_URL` | Full backend URL including `http://` |

---

## Manual Deployment

### Deploy Frontend Manually

```bash
export S3_BUCKET_NAME=starttech-frontend-ceeylla-2026
export CLOUDFRONT_DISTRIBUTION_ID=E2THPV0KPEQC5H
export CLOUDFRONT_DOMAIN=d1nhyre8kou1dm.cloudfront.net

./scripts/deploy-frontend.sh
```

---

### Deploy Backend Manually

```bash
export ECR_REPOSITORY_URL=904233100204.dkr.ecr.eu-west-1.amazonaws.com/starttech-backend
export AWS_REGION=eu-west-1

./scripts/deploy-backend.sh latest
```

---

### Check Backend Health

```bash
./scripts/health-check.sh starttech-alb-1944874729.eu-west-1.elb.amazonaws.com
```

---

### Roll Back Backend Deployment

#### List Available Images

```bash
aws ecr list-images --repository-name starttech-backend
```

#### Roll Back to a Previous Image

```bash
export ECR_REPOSITORY_URL=904233100204.dkr.ecr.eu-west-1.amazonaws.com/starttech-backend

./scripts/rollback.sh PREVIOUS_IMAGE_TAG
```

---

## Health Check

The backend exposes a health endpoint:

```bash
curl http://starttech-alb-1944874729.eu-west-1.elb.amazonaws.com/health
```

### Expected Response

```json
{
  "database": "disabled",
  "cache": "ok"
}
```

---

## Technologies Used

### Frontend

- React
- Vite
- TypeScript

### Backend

- Go
- Gin Framework
- MongoDB Atlas
- Redis

### Infrastructure & DevOps

- AWS EC2
- AWS ALB
- AWS S3
- AWS CloudFront
- AWS ECR
- AWS Systems Manager (SSM)
- GitHub Actions
- Docker
- Terraform