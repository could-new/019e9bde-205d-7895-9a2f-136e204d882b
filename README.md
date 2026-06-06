# FIFO Document Tracker

A Flutter application designed for managing documents and inventory using the First-In-First-Out (FIFO) method. Users can add batches of items and consume them; the system automatically deducts from the oldest batches first.

## Features
- Add inventory/documents with auto-recorded timestamps.
- Consume quantities of a specific item, automatically removing from the oldest batches first.
- View current stock in a clean list format.
- Remove individual batches manually if needed.

## Stack
- Flutter
- intl (for date formatting)
- uuid (for generating batch IDs)

## Setup
1. Run `flutter pub get`.
2. Run `flutter run`.

---
## CouldAI
This app was generated with [CouldAI](https://could.ai), an AI app builder for cross-platform apps that turns prompts into real native iOS, Android, Web, and Desktop apps with autonomous AI agents that architect, build, test, deploy, and iterate production-ready applications.
