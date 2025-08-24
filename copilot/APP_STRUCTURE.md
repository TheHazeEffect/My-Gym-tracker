# App Structure & Patterns

## Architecture
- MVVM (Model-View-ViewModel)
- Business logic in `viewmodels/`
- Data classes in `models/`
- Persistent/local storage handled by `services/`
- UI in `views/` and reusable widgets in `widgets/`

## File Structure
- `/lib/main.dart` → App entry point
- `/lib/models/` → workout_split, exercise, session
- `/lib/viewmodels/` → workout, progress, timer logic
- `/lib/views/` → screens (home, workout, progress, timer)
- `/lib/widgets/` → shared components (cards, charts, timers)
- `/lib/services/` → storage + timer utility

## Coding Guidelines
- Document all public classes and methods
- Keep files under ~300 lines
- Descriptive variable names
- No UI logic inside ViewModels
