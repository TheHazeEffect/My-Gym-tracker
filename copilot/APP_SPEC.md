# Gym Tracker App Specification

## Overview
A Flutter app that allows users to:
- Configure workout splits (e.g., Push/Pull/Legs, Upper/Lower)
- Track gym sessions, logging sets/reps/weight
- Keep track of personal records (highest weight, total volume, max reps per exercise)
- Include a rest timer, with the ability to set multiple timers

## Features
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


Additional Details: How I expect to use the app. 
- I will go to the gym and start a workout, this will send me to the workout details screen.
- on the workout details screen I will be able to add exercises to the workout, Exercise options will span a list of historically done exercises with the ability to add a new exercise
- After adding an exercise to the workout details screen, I can add/track each set I do for that exercise
- I will be able to track the progressions for all my exercises by looking at an progress section of the app. this will show a list of each workout where I see the maximum working set (Rep and weight)
- For the progression data, I want to see the weight moved instead of the volume and I want a graph at the top that shows the change in weight moved over time
- When creating an exercise, I can optiionally specify what primary, secondary and terierty muscle groups are being targetted.
- After ending a workout all workout data will be logged and I'll be able to see the new exercise progression details in progression section of my app

- Also allow me to see details and the ability to edit past workouts as well
- Timers should also alarm/alert me. Timers should also not delete on completion. I should be able to start the same timer multiple times. as in. Setting a 3 minute timer and then another 3 minute timer a minute later to potentilly time two different things (FOr example rest times when doing multiple workouts)


- I should be able to see my past workouts in the workout section, It starts by showing me a calender where I can swipe between months to see all the workouts in that month both in a list below as well as as highlights on the calendar, where i could even select a day to see only the workouts on that day. selecitng the day again remove the day filter and goes back to showing me all the workouts in that month