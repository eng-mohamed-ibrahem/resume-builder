# ResuMate - ATS Resume Builder

ResuMate is a modern, powerful, and ATS-friendly resume builder application built with **Flutter**. It empowers users to create professional resumes with ease, offering real-time previews, drag-and-drop customization, and seamless PDF export capabilities.

## 🚀 Features

- **ATS-Friendly Optimization**: Built with Application Tracking Systems in mind to ensure your resume gets seen by recruiters.
- **Real-Time Preview**: See changes instantly as you edit your resume sections.
- **Drag & Drop Sections**: Easily reorder resume sections (Experience, Education, Skills, etc.) with a intuitive drag-and-drop interface.
- **Professional Templates**: Clean and modern templates designed for maximum readability.
- **PDF Export**: Generate high-quality PDF files ready for job applications.
- **Cloud Sync & Storage**: Securely save your resumes to the cloud using **Supabase** integration.
- **Authentication**: Secure user sign-up and login functionality.

## � Why Choose ResuMate?

**1. Defeating the "Formatting Nightmare"**
- **Word**: You move one image slightly to the left, and suddenly your entire document layout explodes. You spend 50% of your time fighting margins, tabs, and bullet points.
- **ResuMate**: Focus 100% on **content**. The app handles layout, spacing, and typography automatically, guaranteeing a polished look without the frustration.

**2. Guaranteed ATS Compatibility**
- **Word**: It's easy to accidentally use columns or text boxes that Application Tracking Systems (ATS) cannot read, getting you auto-rejected.
- **ResuMate**: Engineered to be **machine-readable**. The structure is standardized so ATS software can easily parse your Name, Experience, and Skills.

**3. Instant Re-ordering (Drag & Drop)**
- **Word**: Swapping sections involves cutting, pasting, and fixing broken spacing.
- **ResuMate**: Simply **click and drag**. Sections swap instantly and the document flows perfectly.

**4. Professional Consistency**
- **Word**: Manual adjustments often lead to inconsistent font sizes and misaligned headers.
- **ResuMate**: The design system enforces strict consistency. All headers, body text, and dates are perfectly aligned.

**5. Live Preview vs. Blind Edits**
- **Word**: Edit -> Save as PDF -> Check PDF -> Repeat when you find a broken line.
- **ResuMate**: **Real-Time Preview** side-by-side means you see exactly how your resume looks as you type.

## �🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Flutter Bloc](https://pub.dev/packages/flutter_bloc) / Cubit
- **Backend**: [Supabase](https://supabase.com/) (PostgreSQL, Auth)
- **PDF Generation**: [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing)
- **UI Components**: Custom widgets with detailed animations and responsive design.

## 📁 Project Structure

The project follows a Clean Architecture inspired structure:

```
lib/
├── core/             # Shared services, utilities, and constants
├── features/         # Feature-based organization
│   ├── auth/         # Authentication logic and screens
│   └── resume/       # Resume building core logic
│       ├── data/     # Repositories and data models
│       ├── domain/   # Business entities and use cases
│       └── presentation/ # UI (Pages, Search, Widgets)
├── main.dart         # Entry point
└── app.dart          # App configuration
```

## 🏁 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- A [Supabase](https://supabase.com/) account for backend services.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/resumate.git
    cd resumate
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Configure Supabase**:
    - Create a new project on Supabase.
    - Run the SQL schema provided in `supabase_schema.sql` in your Supabase SQL Editor to set up the database tables.
    - Create a `.env` file in the root directory (or update `main.dart` directly if not using dotenv) with your credentials:
      ```env
      SUPABASE_URL=your_project_url
      SUPABASE_ANON_KEY=your_anon_key
      ```

4.  **Run the application**:
    ```bash
    flutter run
    ```

## 📄 Supabase Setup

For a detailed guide on setting up the backend, please refer to the [Supabase Integration Guide](supabase_integration_guide.md) included in this repository. It covers:
- Database Schema setup
- Authentication configuration
- RLS Policies

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the project
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
