# SplitSet

Don't think, lift.

SplitSet is a watchOS-first resistance training companion. Design your routines on iPhone with exercises, sets, reps, and rest periods — then leave your phone in your bag. SplitSet walks you through every set, rest, and rep directly from your Apple Watch, with live heart rate, haptic cues, and optional weight logging via the Digital Crown.

## Why SplitSet?

Most workout apps compete for your attention. SplitSet gets out of the way. Do the thinking once on your phone — what to lift, how many reps, how long to rest — then forget it. At the gym, your watch is your coach. It tells you what's next, counts down your rest, and keeps you moving. Your only job is the rep.

## Features

- **Watch-first workout player** — the full workout experience runs on Apple Watch with no phone required at the gym
- **Step-by-step guidance** — the watch walks you through each set in order, with rest countdowns and auto-advance between exercises
- **Flexible set configuration** — uniform sets for simple routines, or configure each set individually for progressive overload
- **To-failure / AMRAP sets** — mark any set as to-failure; the watch shows "To failure" instead of a rep target
- **Timed sets** — duration-based sets with auto-countdown for cardio finishers, planks, or any timed work
- **Live heart rate** — real-time heart rate monitoring throughout the workout via an active HealthKit workout session
- **Weight tracking** — optionally log the weight used per set using the Digital Crown; pre-fills from your last session
- **Lift speed tracking** — optionally measure acceleration during each set using the watch's motion sensor; shows a live g-force readout while you lift and saves peak and average values per set
- **Rest pre-start** — rest countdown begins the moment you finish a set, running in the background while you log weight so no recovery time is wasted
- **Haptic feedback** — haptics signal set completion, rest start/end, and workout completion so you don't have to watch the screen
- **Workout countdown** — a 3-2-1-Go countdown with haptics eases you into each workout before the first set appears
- **Scrollable notes** — exercise notes scroll with the Digital Crown so long cues are never truncated
- **Automatic sync** — workouts sync from iPhone to Apple Watch via WatchConnectivity whenever you make changes
- **Session history** — completed sessions sync back to the iPhone automatically; review past sessions with per-set weights and lift speed from the workout detail screen
- **History export** — share any workout's full session history as a Markdown file, including exercise notes, weights, and acceleration data

## How It Works

```
 iPhone                          Apple Watch
┌──────────────────┐            ┌──────────────────┐
│  Build workouts  │ ─────────► │  Execute workout  │
│  Add exercises   │            │  Step-by-step     │
│  Configure sets  │            │  HR + haptics     │
│  Set rest times  │            │  Log weights      │
│                  │            │  Lift speed       │
│  View history    │ ◄───────── │  Sync session     │
│  Export backup   │            └──────────────────┘
└──────────────────┘
```

1. **Build** — Create workouts on iPhone. Add exercises, set rep targets or durations, suggest weights, and configure rest periods. Optionally enable weight logging and lift speed tracking per workout.
2. **Sync** — Workouts automatically sync to your Apple Watch.
3. **Lift** — Start a workout on your watch. Follow the guided steps — lift, rest, repeat. Haptics keep you on track without looking at the screen.
4. **Log** — Optionally log weights per set with the Digital Crown. Your last weight pre-fills for next time.
5. **Review** — Completed sessions sync back to your iPhone. View history per workout, compare sessions, and export as Markdown for backup.

## Project Structure

```
SplitSet/
├── SplitSetCore/           Shared Swift package — domain models
│   ├── Workout             Name, exercise list, weight/acceleration toggles
│   ├── Exercise            Name, ordered sets, notes, rest duration
│   ├── ExerciseSet         Rep target or duration, suggested weight
│   ├── WorkoutStep         Runtime enum: .lift or .rest
│   ├── WorkoutSession      Completed session with set logs and timestamps
│   ├── SetLog              Completed set — weight and lift acceleration data
│   └── LiftAccelerationData  Peak and average g-force per set
├── SplitSet/               iOS app — workout builder and history
│   ├── WorkoutListView     Browse, create, and delete workouts
│   ├── WorkoutDetailView   Per-exercise set breakdown
│   ├── WorkoutEditView     Create/edit a workout and its exercises
│   ├── ExerciseEditView    Uniform or per-set configuration
│   ├── WorkoutHistoryView  Past sessions with per-set weights and lift speed
│   ├── HelpView            Getting started guide and tips
│   ├── HistoryTransferable Markdown export of session history
│   └── Connectivity        WatchConnectivity — sync workouts out, sessions in
└── SplitSetWatch/          watchOS app — workout player
    ├── WorkoutPlayerView   Step-by-step player with HR header and start countdown
    ├── CountdownView       3-2-1-Go pre-workout countdown screen
    ├── LiftStepView        Active set — exercise, reps, weight, live g-force
    ├── TimedSetView        Timed set with countdown
    ├── RestStepView        Rest countdown with next-up preview
    ├── WeightPickerView    Digital Crown weight logger with live rest indicator
    ├── MotionManager       CoreMotion lift acceleration tracking
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

- [x] Workout history — review past sessions and logged weights
- [x] Weight sync — push completed set logs back to the phone
- [x] Lift speed tracking — measure acceleration per set via Apple Watch motion sensor
- [ ] Workout templates — built-in starter routines
- [ ] Rest timer customization on watch — adjust rest on the fly
