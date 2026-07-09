# Plot

Plot is a desktop-style habit tracker built around GitHub contribution-calendar cells.

The app is designed for tracking habits visually, one day at a time. Each habit has its own contribution-style calendar, streak stats, weekly mini activity cells, and local SQLite persistence.

## Features

- Desktop-first Flutter UI
- GitHub-style habit calendar
- Habit creation and editing
- Habit color selection
- Current streak tracking
- Longest streak tracking
- Days planted over the last 52 weeks
- Weekly mini cells in the sidebar
- Local SQLite persistence
- Desktop window sizing support
- Widget tests for core UI flows

## Tech Stack

- Dart
- Flutter
- Material Design 3
- Riverpod
- GoRouter
- Drift
- SQLite
- flutter_local_notifications
- fl_chart
- window_manager
- flutter_test
- mocktail
- very_good_analysis
- GitHub Actions

## Project Structure

```text
lib/
├── app/
│   ├── app_router.dart
│   └── plot_app.dart
├── core/
│   ├── database/
│   ├── services/
│   └── theme/
├── features/
│   ├── dashboard/
│   └── habits/
├── widgets/
└── main.dart
```


## Persistence
Plot is local-first.

Habit data is stored in a local SQLite database using Drift.

The database file is created as:
plot.sqlite

The main tables are:
habits
habit_entries
habits stores habit metadata such as name, color, and creation time.
habit_entries stores planted calendar days for each habit.

## License
