# SplitSet

A watchOS workout companion app for guided resistance training. Build your routines on iPhone, then leave your phone in your bag — SplitSet walks you through every set, rest, and rep directly from your wrist.

## Features

- **Watch-first** — the full workout experience runs on Apple Watch with no phone required at the gym
- **Step-by-step guidance** — the watch walks you through each set in order, with rest countdowns between them
- **Flexible set configuration** — uniform sets for simple routines, or configure each set individually for progressive overload
- **To-failure sets** — mark any set as AMRAP; the watch shows "To failure" instead of a rep target
- **Live heart rate** — heart rate is visible throughout the entire workout via an active `HKWorkoutSession`
- **Weight tracking** — optionally log the weight used per set using the Digital Crown; pre-fills from your last session
- **Haptic feedback** — haptics signal set completion, rest start/end, and workout completion

## Project Structure

```
SplitSet/
├── SplitSetCore/           Shared Swift package — models used by both targets
│   ├── Workout             Name, exercise list, weight tracking toggle
│   ├── Exercise            Name, ordered list of ExerciseSets, notes
│   ├── ExerciseSet         Per-set rep target, suggested weight, rest duration
│   ├── WorkoutStep         Runtime enum: .lift or .rest (generated from exercises)
│   ├── WorkoutSession      Active session state and set logs
│   └── SetLog              Completed set record — actual reps and weight
├── SplitSet/               iOS app — workout builder
│   ├── WorkoutListView     Browse, create, and delete workouts
│   ├── WorkoutDetailView   Per-exercise set breakdown
│   ├── WorkoutEditView     Create/edit a workout and its exercises
│   ├── ExerciseEditView    Add exercises with uniform or per-set configuration
│   └── ExerciseSetEditView Edit an individual set's reps, weight, and rest
└── SplitSetWatch/          watchOS app — workout player
    ├── WorkoutPlayerView   Step-by-step player with HR header
    ├── LiftStepView        Active set screen — exercise, set number, rep target
    ├── RestStepView        Rest countdown with next-up preview
    ├── WeightPickerView    Digital Crown weight logger
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

- [ ] WatchConnectivity — sync workouts from phone to watch
- [ ] SwiftData persistence — save workouts and history across launches
- [ ] Workout history — review past sessions and logged weights
- [ ] WatchConnectivity weight sync — push completed set logs back to the phone
