# Gemma 3N App

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue?logo=flutter)](https://flutter.dev/) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, privacy-first AI chatbot app for Android and iOS, running Google's **Gemma 3N** model entirely on-device. Supports both text and image (multimodal) conversations, with a beautiful, accessible UI and robust offline capabilities.

---

## 🚀 Features

- **Local AI Processing**: All inference runs on your device—no cloud required, ensuring privacy and offline use.
- **Gemma 3N E2B IT Model**: 1.5B parameter, instruction-tuned, multimodal (text + image) model from Google, optimized for mobile.
- **Multimodal Chat**: Send text, images, or both. Get AI insights on photos, screenshots, and more.
- **Smart Model Management**: Guided download, resumable progress, and update checks for the 3.1GB model file.
- **Persistent Conversation History**: Your chats are stored locally and can be exported/imported as JSON.
- **Rich UI/UX**: Clean, accessible chat interface with light/dark mode, error handling, and conversation stats.
- **Privacy by Design**: No data leaves your device. All processing and storage is local.

---

## 📱 Video Tutorial

[![Watch the video tutorial](https://img.youtube.com/vi/RdVVzf1DwaY/0.jpg)](https://www.youtube.com/watch?v=RdVVzf1DwaY)

---

## 🛠️ Getting Started

### Prerequisites
- **Flutter SDK**: >=3.8.1
- **Android**: API 24+ (Android 7.0+), 4GB+ RAM, 4GB+ free storage
- **iOS**: iOS 16.0+, 4GB+ RAM, 4GB+ free storage

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/gemma3n_app.git
cd gemma3n_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment
- Create a `.env` and add your [Hugging Face token](https://huggingface.co/settings/tokens) as `HF_TOKEN=your_token_here`.
- Or, enter your token in the app during first launch.

### 4. Run the App
- **Android:**
  ```bash
  flutter run -d android
  ```
- **iOS:**
  ```bash
  flutter run -d ios
  ```

---

## 🤖 Model Download & Setup
- On first launch, you'll be guided to download the Gemma 3N model (~3.1GB).
- Requires a Hugging Face account and token (free for most users).
- Download progress, errors, and status are shown in-app.
- Model is stored securely in your app's documents directory.

---

## ✨ Usage
- **Chat**: Type messages or attach images to interact with the AI.
- **Multimodal**: Combine text and images for richer queries (e.g., "Describe this photo").
- **Conversation Management**: View stats, clear history, or export/import conversations.
- **Model Management**: Check model status, update, or re-download as needed.

---

### Key Components
- **ModelManager**: Handles download, initialization, and lifecycle of the Gemma model.
- **ChatService**: Manages conversation flow, message persistence, and AI inference.
- **ImageService**: Handles image picking, compression, and cleanup for multimodal queries.
- **UI Layer**: Modern, accessible chat interface with theming and error handling.

---

## 🎨 Theming & Accessibility
- **Light & Dark Mode**: Auto-detects system theme, with custom color palettes for both.
- **Typography**: Large, readable fonts with proper contrast.
- **Accessibility**: Screen reader support, large touch targets, and high-contrast options.
- **Style Guide**: See [STYLE_GUIDE.md](STYLE_GUIDE.md) for design tokens, layout, and component specs.

---

## 🔒 Privacy & Security
- **All AI processing is local**—no user data or queries are sent to external servers.
- **Conversations and images are stored only on your device**.
- **Clear all data**: Option to delete conversation history and model files at any time.

---

## 🧑‍💻 Contributing

We welcome contributions! Please:
- Follow the [STYLE_GUIDE.md](STYLE_GUIDE.md) for code and UI consistency.
- Write clear commit messages and document your code.
- Add tests for new features where possible.
- Open issues or pull requests for bugs, ideas, or improvements.

---

## 🐞 Troubleshooting
- **Model download fails**: Check your Hugging Face token and internet connection. Resume is supported.
- **App crashes on startup**: Ensure your device meets the RAM/storage requirements.
- **Image upload issues**: Grant storage/camera permissions and use supported formats (JPEG, PNG, WebP).
- **Other issues**: See [PROJECT_REQUIREMENTS.md](PROJECT_REQUIREMENTS.md) for known risks and mitigations.

---

## 🙏 Acknowledgements
- [Google Gemma 3N](https://ai.google.dev/gemma)
- [Flutter Gemma Plugin](https://pub.dev/packages/flutter_gemma)
- [Flutter](https://flutter.dev/)
- [Hugging Face](https://huggingface.co/)

---

For more details, see [PROJECT_REQUIREMENTS.md](PROJECT_REQUIREMENTS.md) and [STYLE_GUIDE.md](STYLE_GUIDE.md).
