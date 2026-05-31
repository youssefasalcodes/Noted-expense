# PyArmor Configuration for Pharmacy Expense Tracker
# This file provides advanced code obfuscation settings

import os
import sys

# PyArmor Configuration
PYARMOR_CONFIG = {
    # Obfuscation mode
    'obf_mode': 1,  # 0 = normal, 1 = advanced
    
    # Restrict mode (prevents reverse engineering)
    'restrict_mode': 1,  # 0 = no restriction, 1 = restrict
    
    # License expiration (optional - set to 0 for permanent)
    'expired_days': 0,  # 0 = permanent, N = expire after N days
    
    # Hardware binding (optional - binds to specific machine)
    'bind_disk': False,  # Bind to hard disk serial number
    'bind_mac': False,  # Bind to MAC address
    
    # Encryption options
    'packages': [],  # Packages to obfuscate (empty = all)
    'exclude_modules': ['tkinter', 'matplotlib', 'pandas', 'numpy'],  # Exclude from obfuscation
    
    # Output settings
    'output': 'build_secure/obfuscated',
    'entry': 'Test.py',  # Main entry point
    
    # Advanced options
    'assert_call': False,  # Add runtime assertion calls
    'assert_py': False,   # Add Python runtime assertions
    'obf_code': 1,        # Obfuscate code structure
}

def apply_pyarmor_protection(source_file, output_dir):
    """
    Apply PyArmor protection to the main application file
    
    Args:
        source_file: Path to the main Python file
        output_dir: Directory for obfuscated output
    """
    try:
        import subprocess
        
        # Build PyArmor command
        cmd = [
            'pyarmor', 'gen',
            '--output', output_dir,
            '--obf-mode', str(PYARMOR_CONFIG['obf_mode']),
            '--restrict', str(PYARMOR_CONFIG['restrict_mode']),
        ]
        
        # Add expiration if configured
        if PYARMOR_CONFIG['expired_days'] > 0:
            cmd.extend(['--expired', str(PYARMOR_CONFIG['expired_days']), 'days'])
        
        # Add hardware binding if configured
        if PYARMOR_CONFIG['bind_disk']:
            cmd.append('--bind-disk')
        if PYARMOR_CONFIG['bind_mac']:
            cmd.append('--bind-mac')
        
        cmd.append(source_file)
        
        # Execute PyArmor
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"PyArmor protection applied successfully to {source_file}")
            return True
        else:
            print(f"PyArmor protection failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"Error applying PyArmor protection: {e}")
        return False

def verify_pyarmor_installation():
    """Check if PyArmor is installed and working"""
    try:
        import subprocess
        result = subprocess.run(['pyarmor', '--version'], capture_output=True, text=True)
        return result.returncode == 0
    except Exception:
        return False

if __name__ == '__main__':
    # Test PyArmor installation
    if verify_pyarmor_installation():
        print("PyArmor is installed and working")
    else:
        print("PyArmor is not installed. Install with: pip install pyarmor")