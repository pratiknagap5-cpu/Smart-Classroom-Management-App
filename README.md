# 🏫 Smart Classroom Management App

A modern, intuitive, and premium Flutter application designed for educators to streamline student tracking, attendance, and fee management.

[![GitHub Pages](https://img.shields.io/badge/Platform-GitHub%20Pages-blue?logo=github)](https://pratiknagap5-cpu.github.io/Smart-Classroom-Management-App/)
[![Firebase](https://img.shields.io/badge/Database-Firebase-orange?logo=firebase)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Live Demo
**View the live web application here: [Smart Classroom Web (GitHub Pages)](https://pratiknagap5-cpu.github.io/Smart-Classroom-Management-App/)**

## ✨ Key Features

- **📊 Dashboard Overview**: Real-time summary of total students, daily attendance (Present/Absent), and pending fees.
- **👥 Student Management**: Easily add, edit, and view student profiles with class-wise filtering.
- **✅ Attendance Tracking**: Modern interface to mark daily attendance for each class.
- **💰 Fee Management**: Track payment status (Paid, Partial, Unpaid) and managed pending dues.
- **📥 Data Export (JSON)**: Export all app data as a JSON backup directly from the Settings menu.
- **📱 Responsive UI**: Fully responsive indigo-themed interface designed for both desktop and mobile browsers.

## 🛠 Tech Stack

- **Framework**: Flutter (Web & Mobile)
- **Backend**: Firebase Auth & Core
- **Local Storage**: Hive (NoSQL) for fast, offline-first data access
- **State Management**: Provider
- **Theme**: Premium Indigo Palette with standard Path URL Strategy for clean routing.

## 📦 Installation & Setup

1. **Clone the Repo**
   ```bash
   git clone https://github.com/pratiknagap5-cpu/Smart-Classroom-Management-App
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Ensure `lib/firebase_options.dart` is correctly configured for your Firebase project.
   - For Android, place `google-services.json` in `android/app/`.

4. **Run the App**
   ```bash
   flutter run -d chrome
   ```

## 🌐 Deployment (GitHub Pages)

The project is configured for automated deployment via GitHub Actions.

1. **Push to GitHub**: Whenever you push code to the `main` branch, the `.github/workflows/deploy.yml` workflow will automatically:
   - Build the Flutter web project with the correct `--base-href`.
   - Deploy the output to the `gh-pages` branch.

2. **Enable GitHub Pages**:
   - Go to your repository on GitHub.
   - Go to **Settings > Pages**.
   - Under **Build and deployment > Branch**, select `gh-pages` and `/ (root)`.
   - Click **Save**.

Your app will be live at `https://<username>.github.io/<repository-name>/`.

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Made with ❤️ for Educators.*
