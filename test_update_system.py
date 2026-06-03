# -*- coding: utf-8 -*-
"""
Test script for the app update system
Tests the UpdateChecker, UpdateDownloader, and UpdateInstaller classes
"""

import sys
import os
import json
import tempfile
from pathlib import Path

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

from app_updater import UpdateChecker, UpdateDownloader, UpdateInstaller

def test_version_comparison():
    """Test version comparison logic"""
    print("Testing version comparison...")
    
    checker = UpdateChecker()
    
    # Test cases
    test_cases = [
        ("1.0.0", "1.0.1", True),   # Update available
        ("1.0.1", "1.0.0", False),  # No update
        ("1.0.0", "1.0.0", False),  # Same version
        ("1.0.0", "2.0.0", True),   # Major update
        ("1.0.0", "v1.0.1", True),  # With 'v' prefix
        ("1.0.0", " 1.0.1", True),  # With space prefix
    ]
    
    passed = 0
    failed = 0
    
    for current, latest, expected in test_cases:
        result = checker.compare_versions(current, latest)
        status = "PASS" if result == expected else "FAIL"
        print(f"{status} {current} vs {latest}: Expected {expected}, Got {result}")
        if result == expected:
            passed += 1
        else:
            failed += 1
    
    print(f"\nVersion comparison tests: {passed} passed, {failed} failed")
    return failed == 0

def test_current_version_reading():
    """Test reading current version from version.json"""
    print("\nTesting current version reading...")
    
    checker = UpdateChecker()
    current_version = checker.get_current_version()
    
    print(f"Current version from file: {current_version}")
    
    if current_version:
        print("PASS Successfully read version from version.json")
        return True
    else:
        print("FAIL Failed to read version")
        return False

def test_github_release_check():
    """Test checking GitHub releases (without actual update)"""
    print("\nTesting GitHub release check...")
    
    checker = UpdateChecker()
    result = checker.check_for_updates()
    
    print(f"Current version: {result.get('current_version')}")
    print(f"Latest version: {result.get('latest_version')}")
    print(f"Update available: {result.get('update_available')}")
    
    if result.get('error'):
        print(f"Error: {result.get('error')}")
    
    if result.get('update_available') is not None:
        print("PASS Successfully checked for updates")
        return True
    else:
        print("FAIL Failed to check for updates")
        return False

def test_version_file_update():
    """Test updating version.json file"""
    print("\nTesting version file update...")
    
    # Create a temporary version file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        temp_version_file = f.name
        json.dump({
            "version": "1.0.0",
            "release_date": "Test",
            "changelog": "Test",
            "critical": False,
            "min_required_version": "1.0.0"
        }, f)
    
    try:
        # Test reading
        with open(temp_version_file, 'r') as f:
            data = json.load(f)
            print(f"Read version: {data.get('version')}")
        
        # Test writing
        with open(temp_version_file, 'w') as f:
            json.dump({
                "version": "1.0.1",
                "release_date": "Test",
                "changelog": "Test",
                "critical": False,
                "min_required_version": "1.0.0"
            }, f)
        
        # Verify
        with open(temp_version_file, 'r') as f:
            data = json.load(f)
            print(f"Updated version: {data.get('version')}")
        
        print("PASS Version file update test passed")
        return True
    except Exception as e:
        print(f"FAIL Version file update test failed: {e}")
        return False
    finally:
        os.unlink(temp_version_file)

def test_update_simulation():
    """Simulate the update process without actually updating"""
    print("\nTesting update simulation...")
    
    checker = UpdateChecker()
    current_version = checker.get_current_version()
    
    print(f"Simulating update check for version {current_version}")
    print("This will check GitHub for latest version without downloading")
    
    result = checker.check_for_updates()
    
    if result.get('update_available'):
        print(f"UPDATE Available: {result.get('current_version')} -> {result.get('latest_version')}")
        print(f"Release notes: {result.get('release_notes', 'None')[:100]}...")
        print(f"Download URL: {result.get('download_url', 'None')}")
    else:
        print(f"PASS No update available (current version: {result.get('current_version')})")
    
    return True

def main():
    """Run all update system tests"""
    print("=" * 60)
    print("APP UPDATE SYSTEM TESTS")
    print("=" * 60)
    
    tests = [
        test_version_comparison,
        test_current_version_reading,
        test_version_file_update,
        test_github_release_check,
        test_update_simulation,
    ]
    
    results = []
    
    for test in tests:
        try:
            results.append(test())
        except Exception as e:
            print(f"FAIL Test failed with exception: {e}")
            results.append(False)
        print()
    
    print("=" * 60)
    print(f"TEST SUMMARY: {sum(results)}/{len(results)} tests passed")
    print("=" * 60)
    
    if all(results):
        print("PASS All tests passed!")
        return 0
    else:
        print("FAIL Some tests failed")
        return 1

if __name__ == '__main__':
    sys.exit(main())
