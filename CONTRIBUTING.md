# Contributing to AutoICS

We welcome contributions from the community to help improve the reliability and efficiency of AutoICS for users around the world.

## 🐞 Bug Reporting

Please include as much detail as possible when reporting a bug:
*   **Logs**: Attach `auto-ics.log`, `service.log`, and `service-error.log` (if any).
*   **Environment**: Mention your Windows version and the Android device used.
*   **Scenario**: What happened? Was it after a reboot, a disconnect, or a specific error?

## ✨ Feature Suggestions

If you have a suggestion for improving the script, feel free to open an issue or start a discussion. We especially value:
*   **Optimization**: Reducing CPU or RAM usage further.
*   **Compatibility**: Support for new types of adapters or Windows versions.
*   **Security**: Improving binary verification or script integrity.

## 🛠 Development Workflow

1.  **Fork** the repository on GitHub.
2.  **Clone** your fork to your local machine.
3.  **Branch**: Create a new branch for your feature or fix: `git checkout -b feature/your-feature-name`.
4.  **Local Dev Setup**:
    *   Enable Developer Mode in Windows 10/11.
    *   Set PowerShell execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`.
    *   Administrator rights are required for testing.
5.  **Test**: Ensure your changes don't break existing name-standardization or service-registration logic.
6.  **PR**: Submit a Pull Request with a clear description of your changes.

## ✅ Pre-Submission Checklist

- [ ] Run `Rename-Adapters.ps1` to ensure it still correctly identifies and names interfaces.
- [ ] Verify `AutoICS.ps1` correctly detects state changes.
- [ ] Check if the Service still starts/stops correctly via `Install-Service.ps1` and `Uninstall-Service.ps1`.
- [ ] Ensure any new logs follow the standard format: `yyyy-MM-dd HH:mm:ss - msg`.
- [ ] Update `CODE_DOCUMENTATION.md` if any core logic or architecture has changed.
