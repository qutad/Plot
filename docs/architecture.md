# Plot Architecture

Plot starts as a local-first desktop app. The desktop client uses SQLite through Drift for embedded storage. PostgreSQL remains a future development or backend target rather than a required runtime dependency for the app.

The first milestone is intentionally UI-first: a desktop shell, habit sidebar, contribution-calendar grid, edit dialog, and Riverpod state with sample data. Persistence, notifications, charts, and release packaging can then be wired into stable feature seams.
