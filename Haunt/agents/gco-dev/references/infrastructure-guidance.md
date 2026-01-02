# Infrastructure Mode Guidance

## Overview

Infrastructure mode applies to:
- IaC configs, CI/CD pipelines, deployment scripts
- File paths: `*terraform/*`, `*.github/*`, `*k8s/*`, `*deploy/*`

## Test Commands

```bash
# Terraform
terraform plan  # Verify state changes
terraform validate  # Syntax check

# Ansible
ansible-playbook --check playbook.yml  # Dry run

# GitHub Actions / CI pipelines
# Validate syntax locally (varies by CI system)

# Docker
docker build -t test .  # Verify build succeeds
```

## Focus Areas

1. **Idempotence** - Scripts can run multiple times without side effects
2. **Secrets management** - Never hardcode secrets, use env vars or secret managers
3. **Rollback capability** - Always have a way to revert changes
4. **Monitoring** - Verify deployments succeed, alert on failures

## Tech Stack Awareness

Common infrastructure technologies:
- **IaC**: Terraform, Ansible, CloudFormation, Pulumi
- **Containers**: Docker, Kubernetes, Docker Compose
- **CI/CD**: GitHub Actions, GitLab CI, CircleCI, Jenkins
- **Cloud Providers**: AWS, GCP, Azure

## Testing Strategy

### Infrastructure Tests

Unlike backend/frontend, infrastructure often requires manual verification:

1. **Syntax validation** - Run linters/validators
2. **Dry run** - Use `--check`, `plan`, `--dry-run` flags
3. **Staging deployment** - Deploy to test environment first
4. **Smoke tests** - Verify critical services start
5. **Rollback test** - Verify you can revert changes

### Example Workflow

```bash
# 1. Syntax check
terraform validate

# 2. Preview changes
terraform plan -out=plan.tfplan

# 3. Apply to staging
terraform apply -target=staging plan.tfplan

# 4. Smoke test staging
curl https://staging.example.com/health

# 5. If successful, apply to production
terraform apply plan.tfplan

# 6. Verify production
curl https://example.com/health

# 7. Monitor for errors
# (Check logs, metrics, alerts)
```

## Common Patterns

### Idempotent Scripts
```bash
# Bad: Creates resource every time
docker run -d --name myapp myapp:latest

# Good: Check if exists first
if ! docker ps -a | grep -q myapp; then
  docker run -d --name myapp myapp:latest
fi
```

### Secret Management
```bash
# Bad: Hardcoded secrets
export API_KEY="sk-1234567890abcdef"

# Good: Load from environment or secret manager
export API_KEY="${API_KEY}"  # From environment
# Or use AWS Secrets Manager, HashiCorp Vault, etc.
```

### Error Handling in Scripts
```bash
# Good: Exit on error, show context
set -euo pipefail

deploy_app() {
  echo "Deploying application..."
  if ! kubectl apply -f deployment.yaml; then
    echo "ERROR: Deployment failed"
    kubectl get pods  # Show current state
    exit 1
  fi
  echo "Deployment successful"
}
```

### Rollback Strategy
```bash
# Always tag/version deployments
docker tag myapp:latest myapp:v1.2.3
docker push myapp:v1.2.3

# Rollback command ready
# docker tag myapp:v1.2.2 myapp:latest
# docker push myapp:latest
# kubectl rollout undo deployment/myapp
```

## Completion Checklist (Infrastructure)

Before marking 🟢 Complete:
- [ ] Syntax validated (`terraform validate`, linters)
- [ ] Dry run successful (`terraform plan`, `ansible --check`)
- [ ] Deployed to staging environment
- [ ] Smoke tests passed (services healthy)
- [ ] Rollback procedure tested
- [ ] Secrets not hardcoded
- [ ] Documentation updated (deployment steps, rollback)
- [ ] Manual verification steps documented in completion notes

## Documentation Requirements

Infrastructure changes MUST include:
- What was changed (resources, configs, scripts)
- Why it was changed (problem solved, improvement made)
- How to verify it works (smoke tests, health checks)
- How to rollback if needed (exact commands)

**Example completion note:**
```markdown
**REQ-XXX Completion Notes:**

**Changes:**
- Updated Kubernetes deployment to use v1.2.3 image
- Increased replica count from 2 to 3
- Added resource limits (CPU: 500m, Memory: 512Mi)

**Verification:**
- `kubectl get pods` shows 3 healthy replicas
- `curl https://api.example.com/health` returns 200
- Metrics show no error spike

**Rollback (if needed):**
kubectl rollout undo deployment/myapp
```

## See Also

- `.haunt/checklists/security-checklist.md` - Security review for infrastructure
- `gco-commit-conventions` skill - Proper commit format for IaC changes
