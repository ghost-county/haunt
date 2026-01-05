"""
Tests for GitHub webhook receiver
"""

import hmac
import hashlib
import json
import pytest


# Mock Flask app for testing
class MockRequest:
    """Mock request object for testing"""
    def __init__(self, data, headers):
        self.data = data
        self.headers = headers
        self.json_data = json.loads(data) if data else {}
        self.remote_addr = '127.0.0.1'

    def get_data(self):
        return self.data

    @property
    def json(self):
        return self.json_data


class TestWebhookSignatureValidation:
    """Test webhook signature validation"""

    def test_valid_signature(self):
        """Test that valid signature passes validation"""
        secret = 'test-secret-key'
        payload = b'{"test": "data"}'

        # Generate valid signature
        expected_signature = 'sha256=' + hmac.new(
            secret.encode(),
            payload,
            hashlib.sha256
        ).hexdigest()

        # Validate
        result = self.validate_signature(payload, expected_signature, secret)
        assert result is True

    def test_invalid_signature(self):
        """Test that invalid signature fails validation"""
        secret = 'test-secret-key'
        payload = b'{"test": "data"}'
        wrong_signature = 'sha256=wrongsignature'

        result = self.validate_signature(payload, wrong_signature, secret)
        assert result is False

    def test_missing_signature(self):
        """Test that missing signature fails validation"""
        secret = 'test-secret-key'
        payload = b'{"test": "data"}'

        result = self.validate_signature(payload, None, secret)
        assert result is False

    def test_wrong_secret(self):
        """Test that signature with wrong secret fails validation"""
        secret = 'correct-secret'
        wrong_secret = 'wrong-secret'
        payload = b'{"test": "data"}'

        # Generate signature with wrong secret
        signature = 'sha256=' + hmac.new(
            wrong_secret.encode(),
            payload,
            hashlib.sha256
        ).hexdigest()

        result = self.validate_signature(payload, signature, secret)
        assert result is False

    @staticmethod
    def validate_signature(payload_body: bytes, signature_header: str, secret: str) -> bool:
        """Helper method to validate signature (duplicates webhook_receiver logic)"""
        if not signature_header:
            return False

        expected_signature = 'sha256=' + hmac.new(
            secret.encode(),
            payload_body,
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(signature_header, expected_signature)


class TestMarkerDetection:
    """Test @haunt marker detection"""

    def test_marker_in_issue_body(self):
        """Test marker detection in issue body"""
        issue_body = "This issue needs @haunt attention"
        assert self.has_marker(issue_body, '@haunt', case_sensitive=False) is True

    def test_marker_case_insensitive(self):
        """Test case-insensitive marker detection"""
        issue_body = "This issue needs @HAUNT attention"
        assert self.has_marker(issue_body, '@haunt', case_sensitive=False) is True

    def test_marker_case_sensitive(self):
        """Test case-sensitive marker detection"""
        issue_body = "This issue needs @HAUNT attention"
        assert self.has_marker(issue_body, '@haunt', case_sensitive=True) is False

    def test_no_marker(self):
        """Test when marker is not present"""
        issue_body = "This is a regular issue without marker"
        assert self.has_marker(issue_body, '@haunt', case_sensitive=False) is False

    def test_marker_in_code_block(self):
        """Test marker detection in markdown code block"""
        issue_body = """
        ```python
        # Example: Use @haunt marker in issues
        ```
        """
        # This should still detect the marker (implementation choice)
        assert self.has_marker(issue_body, '@haunt', case_sensitive=False) is True

    def test_empty_body(self):
        """Test marker detection with empty body"""
        assert self.has_marker('', '@haunt', case_sensitive=False) is False
        assert self.has_marker(None, '@haunt', case_sensitive=False) is False

    @staticmethod
    def has_marker(text: str, marker: str, case_sensitive: bool) -> bool:
        """Helper method to detect marker (duplicates webhook_receiver logic)"""
        if not text:
            return False

        if case_sensitive:
            return marker in text
        else:
            return marker.lower() in text.lower()


class TestIssueDataExtraction:
    """Test issue data extraction from webhook payload"""

    def test_extract_issue_metadata(self):
        """Test extraction of issue metadata"""
        payload = {
            'action': 'opened',
            'issue': {
                'id': 12345,
                'number': 42,
                'title': 'Test Issue',
                'body': 'This is a test issue with @haunt marker',
                'state': 'open',
                'labels': [{'name': 'bug'}, {'name': 'priority:high'}],
                'assignees': [{'login': 'testuser'}],
                'user': {'login': 'reporter'},
                'created_at': '2025-12-16T00:00:00Z',
                'updated_at': '2025-12-16T01:00:00Z',
                'html_url': 'https://github.com/owner/repo/issues/42'
            },
            'repository': {
                'full_name': 'owner/repo'
            }
        }

        issue_data = self.extract_issue_data(payload)

        assert issue_data is not None
        assert issue_data['issue_number'] == 42
        assert issue_data['issue_id'] == 12345
        assert issue_data['title'] == 'Test Issue'
        assert issue_data['state'] == 'open'
        assert 'bug' in issue_data['labels']
        assert 'testuser' in issue_data['assignees']
        assert issue_data['creator'] == 'reporter'
        assert issue_data['repository'] == 'owner/repo'
        assert issue_data['marker_location'] == 'issue_body'

    def test_marker_in_comment(self):
        """Test marker detection in comment"""
        payload = {
            'action': 'created',
            'issue': {
                'id': 12345,
                'number': 42,
                'title': 'Test Issue',
                'body': 'No marker in body',
                'state': 'open',
                'labels': [],
                'assignees': [],
                'user': {'login': 'reporter'},
                'created_at': '2025-12-16T00:00:00Z',
                'updated_at': '2025-12-16T01:00:00Z',
                'html_url': 'https://github.com/owner/repo/issues/42'
            },
            'comment': {
                'body': 'Adding @haunt marker in comment'
            },
            'repository': {
                'full_name': 'owner/repo'
            }
        }

        issue_data = self.extract_issue_data(payload)

        assert issue_data is not None
        assert issue_data['marker_location'] == 'comment'

    def test_no_marker_found(self):
        """Test when marker is not found anywhere"""
        payload = {
            'action': 'opened',
            'issue': {
                'id': 12345,
                'number': 42,
                'title': 'Test Issue',
                'body': 'No marker here',
                'state': 'open',
                'labels': [],
                'assignees': [],
                'user': {'login': 'reporter'},
                'created_at': '2025-12-16T00:00:00Z',
                'updated_at': '2025-12-16T01:00:00Z',
                'html_url': 'https://github.com/owner/repo/issues/42'
            },
            'repository': {
                'full_name': 'owner/repo'
            }
        }

        issue_data = self.extract_issue_data(payload)

        # Should return None when no marker found
        assert issue_data is None

    @staticmethod
    def extract_issue_data(payload: dict) -> dict:
        """Helper method to extract issue data (simplified version)"""
        issue = payload.get('issue', {})
        comment = payload.get('comment')

        # Check for marker
        marker = '@haunt'
        marker_found = False
        marker_location = None

        # Check issue body
        if marker.lower() in (issue.get('body', '')).lower():
            marker_found = True
            marker_location = 'issue_body'

        # Check comment
        if not marker_found and comment:
            if marker.lower() in (comment.get('body', '')).lower():
                marker_found = True
                marker_location = 'comment'

        if not marker_found:
            return None

        return {
            'issue_number': issue.get('number'),
            'issue_id': issue.get('id'),
            'title': issue.get('title'),
            'body': issue.get('body', ''),
            'state': issue.get('state'),
            'labels': [label['name'] for label in issue.get('labels', [])],
            'assignees': [assignee['login'] for assignee in issue.get('assignees', [])],
            'creator': issue.get('user', {}).get('login'),
            'created_at': issue.get('created_at'),
            'updated_at': issue.get('updated_at'),
            'url': issue.get('html_url'),
            'repository': payload.get('repository', {}).get('full_name'),
            'marker_location': marker_location,
            'action': payload.get('action'),
        }


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
