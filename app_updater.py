# -*- coding: utf-8 -*-
"""
Noted Expense Auto-Updater Module
Handles checking for updates, downloading, and installing updates from GitHub releases
"""

import os
import sys
import json
import requests
import zipfile
import tempfile
import shutil
import subprocess
from pathlib import Path
from PyQt5 import QtCore, QtWidgets, QtGui
from dotenv import load_dotenv

# Load environment variables from .env file if it exists
load_dotenv()

# Configuration - UPDATE THESE VALUES
GITHUB_REPO = "youssefasalcodes/Noted-Expense"  # Replace with your GitHub username/repo
# Try to get token from multiple sources in order of priority:
# 1. NOTED_EXPENSE_GITHUB_TOKEN (set by modern installer)
# 2. GITHUB_TOKEN (manual environment variable or .env file)
# 3. Empty string (no token, will work for public repos only)
GITHUB_TOKEN = os.environ.get('NOTED_EXPENSE_GITHUB_TOKEN', '') or os.environ.get('GITHUB_TOKEN', '')
VERSION_FILE = "version.json"
CURRENT_VERSION = "1.0.0"


class UpdateChecker:
    """Handles checking for updates from GitHub releases"""
    
    def __init__(self, repo=GITHUB_REPO, token=GITHUB_TOKEN):
        self.repo = repo
        self.token = token
        self.api_url = f"https://api.github.com/repos/{repo}/releases/latest"
        self.headers = {"Accept": "application/vnd.github.v3+json"}
        if token:
            self.headers["Authorization"] = f"token {token}"
    
    def get_current_version(self):
        """Get current version from version file"""
        try:
            if os.path.exists(VERSION_FILE):
                with open(VERSION_FILE, 'r', encoding='utf-8') as f:
                    version_data = json.load(f)
                    return version_data.get('version', CURRENT_VERSION)
            return CURRENT_VERSION
        except Exception as e:
            print(f"Error reading version file: {e}")
            return CURRENT_VERSION
    
    def get_latest_release(self):
        """Get latest release information from GitHub"""
        try:
            response = requests.get(self.api_url, headers=self.headers, timeout=10)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching release info: {e}")
            return None
    
    def compare_versions(self, current, latest):
        """Compare version strings (returns True if latest > current)"""
        try:
            # Check if versions are valid
            if not current or not latest:
                print(f"Error comparing versions: empty version string (current: '{current}', latest: '{latest}')")
                return False
            
            # Strip 'v' or 'V' prefix if present
            current_clean = current.lstrip('vV')
            latest_clean = latest.lstrip('vV')
            
            # Remove any extra whitespace
            current_clean = current_clean.strip()
            latest_clean = latest_clean.strip()
            
            # Split version parts
            current_parts = current_clean.split('.')
            latest_parts = latest_clean.split('.')
            
            # Filter out empty parts
            current_parts = [x for x in current_parts if x]
            latest_parts = [x for x in latest_parts if x]
            
            # Convert to integers
            current_parts = [int(x) for x in current_parts]
            latest_parts = [int(x) for x in latest_parts]
            
            return latest_parts > current_parts
        except Exception as e:
            print(f"Error comparing versions: {e}")
            return False
    
    def check_for_updates(self):
        """Check if updates are available"""
        current_version = self.get_current_version()
        latest_release = self.get_latest_release()
        
        if not latest_release:
            return {
                'update_available': False,
                'error': 'Could not fetch release information',
                'current_version': current_version
            }
        
        latest_version = latest_release.get('tag_name', '').lstrip('v')
        update_available = self.compare_versions(current_version, latest_version)
        
        # Get download URL for Windows executable
        download_url = None
        for asset in latest_release.get('assets', []):
            if asset.get('name', '').endswith('.zip'):
                download_url = asset.get('browser_download_url')
                break
        
        return {
            'update_available': update_available,
            'current_version': current_version,
            'latest_version': latest_version,
            'download_url': download_url,
            'release_notes': latest_release.get('body', ''),
            'critical': latest_release.get('prerelease', False) or 'critical' in latest_release.get('body', '').lower()
        }


class UpdateDownloader:
    """Handles downloading updates"""
    
    def __init__(self, parent_widget=None):
        self.parent_widget = parent_widget
        self.progress_dialog = None
    
    def download_update(self, url, destination):
        """Download update file with progress tracking"""
        try:
            response = requests.get(url, stream=True, timeout=30)
            response.raise_for_status()
            
            total_size = int(response.headers.get('content-length', 0))
            block_size = 8192
            downloaded = 0
            
            with open(destination, 'wb') as f:
                for chunk in response.iter_content(chunk_size=block_size):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        if self.progress_dialog:
                            progress = int((downloaded / total_size) * 100) if total_size > 0 else 0
                            self.progress_dialog.setValue(progress)
                            QtWidgets.QApplication.processEvents()
            
            return True
        except Exception as e:
            print(f"Error downloading update: {e}")
            return False
    
    def download_with_dialog(self, url, destination):
        """Download update with progress dialog"""
        self.progress_dialog = QtWidgets.QProgressDialog("جاري تحميل التحديث...", "إلغاء", 0, 100)
        self.progress_dialog.setWindowTitle("تحديث التطبيق")
        self.progress_dialog.setWindowModality(QtCore.Qt.WindowModal)
        self.progress_dialog.show()
        
        success = self.download_update(url, destination)
        self.progress_dialog.close()
        return success


class UpdateInstaller:
    """Handles installing updates"""
    
    def __init__(self, parent_widget=None):
        self.parent_widget = parent_widget
    
    def install_update(self, zip_path, backup_path=None):
        """Install update from downloaded ZIP file"""
        try:
            # Create backup of current installation
            if backup_path:
                self.create_backup(backup_path)
            
            # Get current application directory
            app_dir = Path(sys.executable).parent if getattr(sys, 'frozen', False) else Path(__file__).parent
            
            # Extract update to temporary directory
            with tempfile.TemporaryDirectory() as temp_dir:
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(temp_dir)
                
                # Copy files from temp directory to app directory
                extracted_dir = Path(temp_dir)
                for item in extracted_dir.iterdir():
                    if item.is_dir():
                        dest = app_dir / item.name
                        if dest.exists():
                            shutil.rmtree(dest)
                        shutil.copytree(item, dest)
                    elif item.is_file():
                        dest = app_dir / item.name
                        shutil.copy2(item, dest)
            
            # Update version file
            version_file = app_dir / VERSION_FILE
            if version_file.exists():
                with open(version_file, 'r', encoding='utf-8') as f:
                    version_data = json.load(f)
                version_data['version'] = version_data.get('version', '1.0.0')  # Will be updated by release process
                with open(version_file, 'w', encoding='utf-8') as f:
                    json.dump(version_data, f, indent=2, ensure_ascii=False)
            
            return True
        except Exception as e:
            print(f"Error installing update: {e}")
            if backup_path:
                self.restore_backup(backup_path)
            return False
    
    def create_backup(self, backup_path):
        """Create backup of current installation"""
        try:
            app_dir = Path(sys.executable).parent if getattr(sys, 'frozen', False) else Path(__file__).parent
            if os.path.exists(backup_path):
                shutil.rmtree(backup_path)
            shutil.copytree(app_dir, backup_path)
        except Exception as e:
            print(f"Error creating backup: {e}")
    
    def restore_backup(self, backup_path):
        """Restore from backup if installation fails"""
        try:
            app_dir = Path(sys.executable).parent if getattr(sys, 'frozen', False) else Path(__file__).parent
            if os.path.exists(backup_path):
                # Remove current installation
                for item in app_dir.iterdir():
                    if item.name != 'backup':  # Don't remove backup directory
                        if item.is_dir():
                            shutil.rmtree(item)
                        else:
                            item.unlink()
                
                # Restore from backup
                for item in Path(backup_path).iterdir():
                    if item.is_dir():
                        shutil.copytree(item, app_dir / item.name)
                    else:
                        shutil.copy2(item, app_dir / item.name)
        except Exception as e:
            print(f"Error restoring backup: {e}")


class UpdateDialog(QtWidgets.QDialog):
    """Dialog for checking and installing updates"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("فحص التحديثات")
        self.setFixedSize(500, 400)
        self.setup_ui()
        self.checker = UpdateChecker()
        self.downloader = UpdateDownloader(self)
        self.installer = UpdateInstaller(self)
    
    def setup_ui(self):
        """Setup the update dialog UI"""
        layout = QtWidgets.QVBoxLayout()
        
        # Title
        title_label = QtWidgets.QLabel("فحص التحديثات")
        title_label.setStyleSheet("font-size: 20px; font-weight: bold; color: #1E3A8A; padding: 10px;")
        title_label.setAlignment(QtCore.Qt.AlignCenter)
        layout.addWidget(title_label)
        
        # Status area
        self.status_label = QtWidgets.QLabel("جاري فحص التحديثات...")
        self.status_label.setStyleSheet("font-size: 14px; padding: 10px; color: #64748B;")
        self.status_label.setAlignment(QtCore.Qt.AlignCenter)
        layout.addWidget(self.status_label)
        
        # Update info area
        self.update_info_text = QtWidgets.QTextEdit()
        self.update_info_text.setReadOnly(True)
        self.update_info_text.setMaximumHeight(150)
        self.update_info_text.setStyleSheet("QTextEdit { background-color: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 8px; padding: 10px; }")
        layout.addWidget(self.update_info_text)
        
        # Buttons
        button_layout = QtWidgets.QHBoxLayout()
        
        self.check_button = QtWidgets.QPushButton("فحص التحديثات")
        self.check_button.setStyleSheet("QPushButton { background-color: #1E3A8A; color: white; font-weight: bold; padding: 10px 20px; border-radius: 8px; } QPushButton:hover { background-color: #3B82F6; }")
        self.check_button.clicked.connect(self.check_for_updates)
        button_layout.addWidget(self.check_button)
        
        self.update_button = QtWidgets.QPushButton("تثبيت التحديث")
        self.update_button.setStyleSheet("QPushButton { background-color: #10B981; color: white; font-weight: bold; padding: 10px 20px; border-radius: 8px; } QPushButton:hover { background-color: #34D399; }")
        self.update_button.setEnabled(False)
        self.update_button.clicked.connect(self.install_update)
        button_layout.addWidget(self.update_button)
        
        self.close_button = QtWidgets.QPushButton("إغلاق")
        self.close_button.setStyleSheet("QPushButton { background-color: #64748B; color: white; font-weight: bold; padding: 10px 20px; border-radius: 8px; } QPushButton:hover { background-color: #94A3B8; }")
        self.close_button.clicked.connect(self.close)
        button_layout.addWidget(self.close_button)
        
        layout.addLayout(button_layout)
        self.setLayout(layout)
    
    def check_for_updates(self):
        """Check for available updates"""
        self.status_label.setText("جاري فحص التحديثات...")
        self.check_button.setEnabled(False)
        self.update_button.setEnabled(False)
        QtWidgets.QApplication.processEvents()
        
        result = self.checker.check_for_updates()
        
        if result.get('error'):
            self.status_label.setText("خطأ في فحص التحديثات")
            self.update_info_text.setText(result['error'])
            self.check_button.setEnabled(True)
            return
        
        if result['update_available']:
            self.status_label.setText(f"تحديث جديد متوفر: {result['latest_version']}")
            info_text = f"الإصدار الحالي: {result['current_version']}\n"
            info_text += f"الإصدار الجديد: {result['latest_version']}\n\n"
            info_text += "ملاحظات الإصدار:\n"
            info_text += result['release_notes'] or "لا توجد ملاحظات"
            
            if result['critical']:
                info_text += "\n\n⚠️ هذا تحديث هام ويُنصح بتثبيته فوراً"
            
            self.update_info_text.setText(info_text)
            self.update_button.setEnabled(True)
            self.update_info = result
        else:
            self.status_label.setText("التطبيق محدث لآخر إصدار")
            self.update_info_text.setText(f"الإصدار الحالي: {result['current_version']}\n\nممتاز! أنت تستخدم أحدث إصدار من التطبيق.")
        
        self.check_button.setEnabled(True)
    
    def install_update(self):
        """Download and install the update"""
        if not hasattr(self, 'update_info'):
            QtWidgets.QMessageBox.warning(self, "خطأ", "لم يتم العثور على معلومات التحديث. يرجى فحص التحديثات أولاً.")
            return
        
        if not self.update_info.get('download_url'):
            QtWidgets.QMessageBox.warning(self, "خطأ", "لا يوجد ملف تحديث متاح لهذا الإصدار.\n\nهذا يعني أن الإصدار الجديد على GitHub لا يحتوي على ملف ZIP قابل للتحميل.\n\nلحل هذه المشكلة:\n1. تأكد من أن الإصدار الجديد يحتوي على ملف ZIP\n2. أو راجع مسؤول النشر لإضافة ملف التحديث")
            return
        
        # Download update
        self.status_label.setText("جاري تحميل التحديث...")
        QtWidgets.QApplication.processEvents()
        
        with tempfile.NamedTemporaryFile(suffix='.zip', delete=False) as temp_file:
            temp_path = temp_file.name
        
        try:
            success = self.downloader.download_with_dialog(self.update_info['download_url'], temp_path)
            
            if not success:
                self.status_label.setText("فشل تحميل التحديث")
                return
            
            # Install update
            self.status_label.setText("جاري تثبيت التحديث...")
            QtWidgets.QApplication.processEvents()
            
            backup_path = os.path.join(os.path.dirname(temp_path), 'backup')
            success = self.installer.install_update(temp_path, backup_path)
            
            if success:
                self.status_label.setText("تم تثبيت التحديث بنجاح!")
                self.update_info_text.setText("تم تثبيت التحديث بنجاح.\n\nسيتم إعادة تشغيل التطبيق.")
                
                # Restart application after short delay
                QtCore.QTimer.singleShot(3000, self.restart_application)
            else:
                self.status_label.setText("فشل تثبيت التحديث")
                self.update_info_text.setText("حدث خطأ أثناء تثبيت التحديث.\nيرجى المحاولة مرة أخرى أو الاتصال بالدعم الفني.")
        
        except Exception as e:
            self.status_label.setText("خطأ في التحديث")
            self.update_info_text.setText(f"حدث خطأ: {str(e)}")
        
        finally:
            if os.path.exists(temp_path):
                os.unlink(temp_path)
    
    def restart_application(self):
        """Restart the application"""
        try:
            if getattr(sys, 'frozen', False):
                # Running as compiled executable
                subprocess.Popen([sys.executable])
            else:
                # Running as Python script
                subprocess.Popen([sys.executable, sys.argv[0]])
            
            self.close()
            sys.exit(0)
        except Exception as e:
            print(f"Error restarting application: {e}")


def check_for_updates_on_startup():
    """Check for updates on application startup (silent check)"""
    try:
        checker = UpdateChecker()
        result = checker.check_for_updates()
        
        if result.get('update_available'):
            if result.get('critical'):
                # Show dialog for critical updates
                return result
            else:
                # Just log for non-critical updates
                print(f"Update available: {result['latest_version']}")
                return result
    except Exception as e:
        print(f"Error checking for updates on startup: {e}")
    
    return None


def show_update_dialog(parent=None):
    """Show the update dialog"""
    dialog = UpdateDialog(parent)
    dialog.exec_()
    return dialog.result() == QtWidgets.QDialog.Accepted


if __name__ == "__main__":
    # Test the updater
    app = QtWidgets.QApplication(sys.argv)
    dialog = UpdateDialog()
    dialog.show()
    sys.exit(app.exec_())