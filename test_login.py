"""Test login error message display."""

def test_invalid_login_shows_error_message():
    """Verify error message appears when login fails with wrong credentials."""
    # This test verifies the HTML/JavaScript login form displays an error
    # message when invalid credentials are provided.
    # The fix corrects:
    # 1. Element ID mismatch: getElementById('loginMessage') vs id="message"
    # 2. Assignment vs comparison: username = DEMO_USERNAME vs ===

    # Read the HTML file and verify fixes
    with open('WebApp.html', 'r') as f:
        content = f.read()

    # Verify element ID is correct
    assert 'id="message"' in content, "Message element must have id='message'"

    # Verify the JavaScript gets the correct element ID
    assert "document.getElementById('message')" in content, \
        "Script must reference getElementById('message')"

    # Verify no incorrect reference to 'loginMessage'
    assert "getElementById('loginMessage')" not in content, \
        "Script must not reference non-existent 'loginMessage' element"

    # Verify username comparison uses === not =
    assert "username === DEMO_USERNAME" in content, \
        "Username check must use === comparison, not assignment"

    # Verify no assignment operator in condition
    lines = content.split('\n')
    for i, line in enumerate(lines, 1):
        if 'if (username' in line and 'DEMO_USERNAME' in line:
            assert '===' in line or '==' in line, \
                f"Line {i}: Username check must use comparison operator, not assignment"
            assert 'username =' not in line or 'username ===' in line, \
                f"Line {i}: Must not use assignment operator in if condition"

if __name__ == '__main__':
    test_invalid_login_shows_error_message()
    print("Test passed!")
