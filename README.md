# SplitSet

Build your workout on iPhone. Execute it on your wrist.

SplitSet is a watchOS-first resistance training companion. Design your routines on iPhone with exercises, sets, reps, and rest periods — then leave your phone in your bag. SplitSet walks you through every set, rest, and rep directly from your Apple Watch, with live heart rate, haptic cues, and optional weight logging via the Digital Crown.

## Why SplitSet?

Most workout apps fight for screen time. SplitSet takes the opposite approach: do the thinking on your phone, then forget about it. At the gym, your watch is your coach — it tells you what to lift, when to rest, and keeps you moving. No scrolling, no searching, no phone in your pocket.

## Features

- **Watch-first workout player** — the full workout experience runs on Apple Watch with no phone required at the gym
- **Step-by-step guidance** — the watch walks you through each set in order, with rest countdowns and auto-advance between exercises
- **Flexible set configuration** — uniform sets for simple routines, or configure each set individually for progressive overload
- **To-failure / AMRAP sets** — mark any set as to-failure; the watch shows "To failure" instead of a rep target
- **Timed sets** — duration-based sets with auto-countdown for cardio finishers, planks, or any timed work
- **Live heart rate** — real-time heart rate monitoring throughout the workout via an active HealthKit workout session
- **Weight tracking** — optionally log the weight used per set using the Digital Crown; pre-fills from your last session
- **Rest pre-start** — rest countdown begins the moment you finish a set, running in the background while you log weight so no recovery time is wasted
- **Haptic feedback** — haptics signal set completion, rest start/end, and workout completion so you don't have to watch the screen
- **Workout countdown** — a 3-2-1-Go countdown with haptics eases you into each workout before the first set appears
- **Scrollable notes** — exercise notes scroll with the Digital Crown so long cues are never truncated
- **Automatic sync** — workouts sync from iPhone to Apple Watch via WatchConnectivity whenever you make changes

## How It Works

```
 iPhone                          Apple Watch
┌──────────────────┐            ┌──────────────────┐
│  Build workouts  │   sync     │  Execute workout  │
│  Add exercises   │ ────────── │  Step-by-step     │
│  Configure sets  │            │  HR + haptics     │
│  Set rest times  │            │  Log weights      │
└──────────────────┘            └──────────────────┘
```

1. **Build** — Create workouts on iPhone. Add exercises, set rep targets or durations, suggest weights, and configure rest periods.
2. **Sync** — Workouts automatically sync to your Apple Watch.
3. **Lift** — Start a workout on your watch. Follow the guided steps — lift, rest, repeat. Haptics keep you on track without looking at the screen.
4. **Log** — Optionally log weights per set with the Digital Crown. Your last weight pre-fills for next time.

## Project Structure

```
SplitSet/
├── SplitSetCore/           Shared Swift package — domain models
│   ├── Workout             Name, exercise list, weight tracking toggle
│   ├── Exercise            Name, ordered sets, notes, rest duration
│   ├── ExerciseSet         Rep target or duration, suggested weight
│   ├── WorkoutStep         Runtime enum: .lift or .rest
│   ├── WorkoutSession      Active session state and set logs
│   └── SetLog              Completed set — actual reps and weight
├── SplitSet/               iOS app — workout builder
│   ├── WorkoutListView     Browse, create, and delete workouts
│   ├── WorkoutDetailView   Per-exercise set breakdown
│   ├── WorkoutEditView     Create/edit a workout and its exercises
│   ├── ExerciseEditView    Uniform or per-set configuration
│   ├── HelpView            Getting started guide and tips
│   └── Connectivity        WatchConnectivity sync to watch
└── SplitSetWatch/          watchOS app — workout player
    ├── WorkoutPlayerView   Step-by-step player with HR header and start countdown
    ├── CountdownView       3-2-1-Go pre-workout countdown screen
    ├── LiftStepView        Active set — exercise, reps, weight, scrollable notes
    ├── TimedSetView        Timed set with countdown
    ├── RestStepView        Rest countdown with next-up preview
    ├── WeightPickerView    Digital Crown weight logger with live rest indicator
    └── HealthKitManager    HKWorkoutSession + live heart rate
```

## Requirements

- Xcode 26+
- iOS 17+ (companion app)
- watchOS 10+ (workout player)

## Getting Started

```bash
git clone https://github.com/tlmorgen/splitset.git
cd splitset
xcodegen generate
open SplitSet.xcodeproj
```

Select the **SplitSet** or **SplitSetWatch** scheme and run on a simulator or device.

> **Note:** Heart rate requires a physical Apple Watch. The simulator will show `-- bpm`.

## Roadmap

- [ ] Workout history — review past sessions and logged weights
- [ ] Weight sync — push completed set logs back to the phone
- [ ] Workout templates — built-in starter routines
- [ ] Rest timer customization on watch — adjust rest on the fly
