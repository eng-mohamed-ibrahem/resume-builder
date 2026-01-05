# Deployment Guide: Flutter Web on GitHub Pages

This guide explains how to deploy the **ResuMate** web application to GitHub Pages.

## 1. Prerequisites

- A GitHub repository for the project.
- Flutter SDK installed and configured.

## 2. Automated Deployment (Recommended)

The easiest way to deploy is using the `peanut` package, which automates the creation of a `gh-pages` branch.

### Install Peanut
```bash
flutter pub global activate peanut
```

### Build and Deploy
Run the following command in your project root:
```bash
flutter pub global run peanut --extra-args "--base-href /resume-builder/"
```

### Push to GitHub
```bash
git push origin --set-upstream gh-pages
```

## 3. Manual Deployment

If you prefer to build manually:

1.  **Build the web project**:
    ```bash
    flutter build web --release --base-href "/<repository-name>/"
    ```
2.  **Create a branch**: Create a new branch named `gh-pages` (if it doesn't exist).
3.  **Copy files**: Copy the contents of the `build/web` folder into the root of the `gh-pages` branch.
4.  **Commit and Push**:
    ```bash
    git add .
    git commit -m "Deploy to GitHub Pages"
    git push origin gh-pages
    ```

## 4. GitHub Configuration

Once the `gh-pages` branch is pushed:

1.  Go to your GitHub repository in the browser.
2.  Navigate to **Settings** > **Pages**.
3.  Under **Build and deployment** > **Branch**, select `gh-pages` and `/ (root)`.
4.  Click **Save**.

Your site will be live at `https://<your-username>.github.io/<repository-name>/`.

---

> [!IMPORTANT]
> **Base-HREF**: If your repository is not at the root domain (e.g., `username.github.io/resumate/`), you **must** build with `--base-href "/resumate/"`. Failure to do this will result in a blank white screen (404 for assets).
