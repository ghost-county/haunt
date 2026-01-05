#!/usr/bin/env python3
"""
MCP Server Verification Script

Tests that the agent-memory MCP server can start and respond without errors.

Usage:
  python3 test-mcp-server.py [--server-path /path/to/server.py]

Exit codes:
  0: Server starts successfully
  1: Server failed to start or encountered errors
  2: Dependencies missing (mcp package not installed)
"""

import sys
import subprocess
import argparse
from pathlib import Path


def test_mcp_dependencies():
    """Check if required dependencies are installed."""
    import importlib.util
    return importlib.util.find_spec("mcp") is not None


def test_mcp_server(server_path: Path, timeout: int = 5) -> bool:
    """
    Test that the MCP server can start without errors.

    Args:
        server_path: Path to the MCP server Python file
        timeout: Seconds to wait before killing the server

    Returns:
        True if server starts successfully, False otherwise
    """
    if not server_path.exists():
        print(f"ERROR: Server not found at {server_path}", file=sys.stderr)
        return False

    try:
        # Start server process
        process = subprocess.Popen(
            [sys.executable, str(server_path)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # Wait briefly to see if it crashes immediately
        try:
            return_code = process.wait(timeout=2)
            # If it exits immediately, check if it's an error
            if return_code != 0:
                stderr = process.stderr.read()
                print(f"ERROR: Server exited with code {return_code}", file=sys.stderr)
                print(f"STDERR: {stderr}", file=sys.stderr)
                return False
            else:
                # Exited cleanly (maybe from --help or similar)
                return True
        except subprocess.TimeoutExpired:
            # Server is still running - this is good!
            # Kill it gracefully
            process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()
            return True

    except Exception as e:
        print(f"ERROR: Exception while testing server: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(description="Test MCP server startup")
    parser.add_argument(
        "--server-path",
        type=Path,
        default=Path.home() / ".claude" / "mcp-servers" / "agent-memory-server.py",
        help="Path to MCP server file (default: ~/.claude/mcp-servers/agent-memory-server.py)"
    )
    args = parser.parse_args()

    print(f"Testing MCP server at: {args.server_path}")

    # Check dependencies first
    if not test_mcp_dependencies():
        print("ERROR: Python 'mcp' package not installed", file=sys.stderr)
        print("Install with: pip install mcp", file=sys.stderr)
        return 2

    print("✓ Dependencies check passed")

    # Test server startup
    if test_mcp_server(args.server_path):
        print("✓ MCP server test passed - server starts successfully")
        return 0
    else:
        print("✗ MCP server test failed - server has errors", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
