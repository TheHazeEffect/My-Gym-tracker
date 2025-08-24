# Gym Tracker App Specification

## Overview
A Flutter app that allows users to:
- Configure workout splits (e.g., Push/Pull/Legs, Upper/Lower)
- Track gym sessions, logging sets/reps/weight
- Keep track of personal records (highest weight, total volume, max reps per exercise)
- Include a rest timer, with the ability to set multiple timers

## Features
- Add, edit, and delete workout splits
- Add exercises to each split
- Log workout sessions with exercises and sets
- Track best performance for each exercise
- Progress view with charts for personal records
- Rest timer with option for multiple concurrent timers
- Offline-first (store locally)

## Target Platforms
- iOS
- Android

## Constraints
- Flutter 3.24+
- Use `provider` for state management
- Use `hive` or `shared_preferences` for local storage
- Use `charts_flutter` or `fl_chart` for progress charts
