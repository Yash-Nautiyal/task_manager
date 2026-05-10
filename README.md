# Klarity - Task Manager App 📝✨

**Flutter Development Internship Assignment Submission for Sankar Group**

Klarity is a robust, clean, and interactive Task Manager application built with Flutter. It leverages Firebase Authentication and Cloud Firestore to provide a seamless, real-time productivity experience. The app implements Clean Architecture and the BLoC pattern for state management to ensure highly scalable, maintainable, and production-ready code.

## 🚀 Key Features

### 1. User Authentication (Firebase Auth)
* **Secure Sign-Up & Login:** Email and password authentication with comprehensive form validation (RegEx email checking, password length).
* **Password Reset:** Integrated Firebase password reset link functionality.
* **Instant State Reactivity:** The UI reactively updates to display user initials and names across the app without requiring a manual refresh.

### 2. Task Management (Cloud Firestore CRUD)
* **Real-Time Synchronization:** Uses Firestore streams so tasks update instantly across all views.
* **Core CRUD Operations:** Users can beautifully Add, Edit, and Delete tasks. 
* **Task Fields:** Every task includes a Title, Description, Due Date, and Status (Ongoing, Overdue, Completed).
* **Delightful UX:** Marking a task as completed triggers a dynamic Confetti explosion effect! 🎉
* **Dynamic Filters:** Real-time "Filter Pills" (All, Ongoing, Overdue, Completed) automatically calculate task counts based on search and date-range inputs.

### 3. REST API Integration
* **Motivational Quotes:** Integrates with `https://api.quotable.io/random` to fetch and display a random motivational Quote and Author on the dashboard.
* **Graceful Degradation:** Free APIs occasionally experience downtime. If the API request times out or fails, the app uses a Result wrapper to safely catch the error and injects a local fallback quote so the UI remains flawless and the user experience is never interrupted.
* **Robust Error Handling:** Uses a functional `Result` pattern to gracefully handle timeout errors or offline states without crashing the app.

### 4. UI/UX & Architecture
* **State Management:** BLoC (Business Logic Component) pattern for separated, testable business logic.
* **Global Error Handling:** Centralized Snackbar system to prevent double-rendering of errors.
* **Theming:** Full Dark/Light mode toggle support with animated transitions.

---

## 🛠️ Setup & Installation Instructions

Follow these steps to run the application locally on your machine.

### Prerequisites
* Flutter SDK (Version 3.19.0 or higher recommended)
* Dart SDK
* Android Studio / Xcode for emulators

### 1. Clone the Repository
```bash
git clone https://github.com/Yash-Nautiyal/task_manager.git
```
### 2. Get depenecies
```bash
cd task_app
```
### 3. Run Project
```bash
flutter pub get
```

## 📂 Folder Structure

The project strictly follows a feature-driven clean architecture structure:

```text
lib/
 ┣ core/              # Constants, routing, themes, failures, and helpers
 ┣ models/            # Data models (Task, Filter, User)
 ┣ screens/           # Main UI screens (Auth, Root, Home)
 ┃ ┣ auth/            # Sign-in, Sign-up, and Auth BLoC
 ┃ ┣ dashboard/       # Dashboard view and Dashboard BLoC
 ┃ ┣ tasks/           # Task list view
 ┃ ┗ root/            # Base IndexedStack for navigation
 ┣ services/          # External communications
 ┃ ┣ api_service.dart       # REST API implementation
 ┃ ┣ auth_service.dart      # Firebase Auth implementation
 ┃ ┗ firestore_service.dart # Cloud Firestore implementation
 ┣ widgets/           # Reusable global UI components (Buttons, Loaders, Dialogs)
 ┗ main.dart          # Entry point and multi-bloc initialization
 ```