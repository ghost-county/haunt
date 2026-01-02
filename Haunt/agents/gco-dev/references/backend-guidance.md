# Backend Mode Guidance

## Overview

Backend mode applies to:
- API endpoints, database models, services, business logic
- File paths: `*/api/*`, `*/services/*`, `*/models/*`, `*/db/*`

## Test Commands

```bash
# Python projects
pytest tests/ -x -q

# Node.js projects
npm test
```

## Focus Areas

1. **API contracts** - Clear request/response interfaces, proper HTTP status codes
2. **Database integrity** - Proper schema design, migrations, constraints, indexes
3. **Error handling** - Comprehensive exception handling, meaningful error messages
4. **Business logic** - Correct implementation of domain rules and validation

## Tech Stack Awareness

Common backend technologies you should recognize:
- **Python**: FastAPI, Flask, Django
- **Node.js**: Express, NestJS
- **Databases**: PostgreSQL, MongoDB, MySQL, Redis
- **ORMs**: SQLAlchemy, Prisma, Mongoose

## Testing Strategy

### Unit Tests
- Test individual functions and methods in isolation
- Mock external dependencies (databases, APIs, file systems)
- Focus on business logic correctness

### Integration Tests
- Test API endpoints end-to-end
- Use test database (not production)
- Verify request/response cycles
- Test error scenarios (400, 401, 403, 404, 500)

### Example Test Structure

```python
# tests/test_api_users.py
def test_get_user_returns_200_with_valid_id():
    response = client.get("/api/users/123")
    assert response.status_code == 200
    assert response.json()["id"] == 123

def test_get_user_returns_404_with_invalid_id():
    response = client.get("/api/users/99999")
    assert response.status_code == 404

def test_create_user_validates_email():
    response = client.post("/api/users", json={"email": "invalid"})
    assert response.status_code == 400
    assert "email" in response.json()["errors"]
```

## Common Patterns

### API Error Handling
```python
# Good: Specific error types with context
try:
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise NotFoundError(f"User {user_id} not found")
except DatabaseError as e:
    logger.error(f"Database error fetching user {user_id}: {e}")
    raise ServiceUnavailable("Database temporarily unavailable")
```

### Database Query Optimization
```python
# Bad: N+1 query problem
users = db.query(User).all()
for user in users:
    posts = db.query(Post).filter(Post.user_id == user.id).all()

# Good: Join or eager loading
users = db.query(User).options(joinedload(User.posts)).all()
```

### Input Validation
```python
# Good: Explicit validation before use
def create_user(data: dict):
    if "email" not in data:
        raise ValidationError("email is required")
    if not is_valid_email(data["email"]):
        raise ValidationError("email must be valid")

    # Safe to use now
    user = User(email=data["email"])
```

## Completion Checklist (Backend)

Before marking 🟢 Complete:
- [ ] All API endpoints tested (happy path + error cases)
- [ ] Database queries optimized (no N+1, proper indexes)
- [ ] Input validation comprehensive
- [ ] Error handling covers all I/O operations
- [ ] Logging added for errors and important operations
- [ ] Tests passing: `pytest tests/` or `npm test`
- [ ] API documentation updated (if applicable)
