import SwiftUI
import SwiftData
import SplitSetCore

struct WorkoutListView: View {
    @Query(sort: \WorkoutModel.createdAt) var workouts: [WorkoutModel]
    @Environment(\.modelContext) var modelContext
    @State private var showingNewWorkout = false
    @State private var showingHelp = false
    @State private var importedWorkoutName: String?
    @State private var importError: String?

    var body: some View {
        NavigationStack {
            mainContent
        }
        .onChange(of: PhoneConnectivityManager.shared.receivedSessions) { _, sessions in
            guard !sessions.isEmpty else { return }
            sessions.forEach { persistSession($0) }
            PhoneConnectivityManager.shared.receivedSessions = []
        }
    }

    private var mainContent: some View {
        Group {
            if workouts.isEmpty {
                emptyState
            } else {
                workoutList
            }
        }
        .navigationTitle("SplitSet")
        .navigationDestination(for: WorkoutModel.self) { workout in
            WorkoutDetailView(workout: workout)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showingHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewWorkout = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingNewWorkout) {
            WorkoutEditView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .onAppear {
            #if DEBUG
            seedSampleData()
            #endif
            let pending = PhoneConnectivityManager.shared.receivedSessions
            if !pending.isEmpty {
                pending.forEach { persistSession($0) }
                PhoneConnectivityManager.shared.receivedSessions = []
            }
            PhoneConnectivityManager.shared.syncWorkouts(workouts)
        }
        .onChange(of: workouts) {
            PhoneConnectivityManager.shared.syncWorkouts(workouts)
        }
        .onOpenURL { url in
            importWorkout(from: url)
        }
        .alert("Workout Imported", isPresented: Binding(
            get: { importedWorkoutName != nil },
            set: { if !$0 { importedWorkoutName = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\"\(importedWorkoutName ?? "")\" has been added to your workouts.")
        }
        .alert("Import Failed", isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importError ?? "The file could not be read.")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 52))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text("No Workouts Yet")
                    .font(.title2.bold())
                    .padding(.top, 24)

                Text("Build your first routine and your\nApple Watch will guide you through it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingNewWorkout = true
            } label: {
                Label("Create Workout", systemImage: "plus")
                    .fontWeight(.semibold)
                    .frame(maxWidth: 260)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 32)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Workout List

    private var workoutList: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink(value: workout) {
                    WorkoutRowView(workout: workout)
                }
            }
            .onDelete(perform: deleteWorkouts)
        }
    }

    private func importWorkout(from url: URL) {
        do {
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }

            let data = try Data(contentsOf: url)
            let imported = try JSONDecoder().decode(Workout.self, from: data)

            let workout = WorkoutModel(name: imported.name, trackWeights: imported.trackWeights)
            for (i, ex) in imported.exercises.enumerated() {
                let exercise = ExerciseModel(
                    name: ex.name,
                    notes: ex.notes,
                    order: i,
                    restSeconds: ex.restSeconds,
                    isUniform: true
                )
                for (j, s) in ex.sets.enumerated() {
                    exercise.sets.append(ExerciseSetModel(
                        targetReps: s.targetReps,
                        durationSeconds: s.durationSeconds,
                        suggestedWeightKg: s.suggestedWeightKg,
                        order: j
                    ))
                }
                workout.exercises.append(exercise)
            }
            modelContext.insert(workout)
            importedWorkoutName = imported.name
        } catch {
            importError = error.localizedDescription
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }

    private func persistSession(_ session: WorkoutSession) {
        let model = SessionModel(
            syncId: session.id,
            workoutSyncId: session.workoutId,
            startDate: session.startDate,
            endDate: session.endDate
        )
        for log in session.setLogs {
            let logModel = SetLogModel(
                syncId: log.id,
                exerciseSetId: log.exerciseSetId,
                setNumber: log.setNumber,
                weightKg: log.weightKg,
                peakAccelerationG: log.accelerationData?.peakAccelerationG,
                averageAccelerationG: log.accelerationData?.averageAccelerationG,
                completedAt: log.completedAt
            )
            model.setLogs.append(logModel)
        }
        modelContext.insert(model)

        // Update suggested weights from logged weights (last log per set wins)
        var latestWeights: [UUID: Double] = [:]
        for log in session.setLogs {
            if let w = log.weightKg {
                latestWeights[log.exerciseSetId] = w
            }
        }
        for (setId, weight) in latestWeights {
            let descriptor = FetchDescriptor<ExerciseSetModel>(
                predicate: #Predicate { $0.syncId == setId }
            )
            if let setModel = try? modelContext.fetch(descriptor).first {
                setModel.suggestedWeightKg = weight
            }
        }

        // Push updated workouts to the watch
        PhoneConnectivityManager.shared.syncWorkouts(workouts)
    }

    #if DEBUG
    private func seedSampleData() {
        guard workouts.isEmpty else { return }

        // Enable acceleration tracking on Chest Day
        let chestSample = Workout.sample
        let chestWorkout = WorkoutModel(name: chestSample.name, trackWeights: chestSample.trackWeights, trackAcceleration: true)
        var chestExerciseSets: [[ExerciseSetModel]] = []
        for (i, ex) in chestSample.exercises.enumerated() {
            let exercise = ExerciseModel(name: ex.name, notes: ex.notes, order: i, restSeconds: ex.restSeconds, isUniform: true)
            var sets: [ExerciseSetModel] = []
            for (j, s) in ex.sets.enumerated() {
                let setModel = ExerciseSetModel(targetReps: s.targetReps, durationSeconds: s.durationSeconds, suggestedWeightKg: s.suggestedWeightKg, order: j)
                exercise.sets.append(setModel)
                sets.append(setModel)
            }
            chestExerciseSets.append(sets)
            chestWorkout.exercises.append(exercise)
        }
        modelContext.insert(chestWorkout)

        for sample in Workout.samples.dropFirst() {
            let workout = WorkoutModel(name: sample.name, trackWeights: sample.trackWeights)
            for (i, ex) in sample.exercises.enumerated() {
                let exercise = ExerciseModel(name: ex.name, notes: ex.notes, order: i, restSeconds: ex.restSeconds, isUniform: true)
                for (j, s) in ex.sets.enumerated() {
                    exercise.sets.append(ExerciseSetModel(targetReps: s.targetReps, durationSeconds: s.durationSeconds, suggestedWeightKg: s.suggestedWeightKg, order: j))
                }
                workout.exercises.append(exercise)
            }
            modelContext.insert(workout)
        }

        seedSampleSessions(for: chestWorkout, exerciseSets: chestExerciseSets)
    }

    // Seed 3 past sessions for Chest Day with realistic weight and acceleration data
    private func seedSampleSessions(for workout: WorkoutModel, exerciseSets: [[ExerciseSetModel]]) {
        // Weights per exercise (kg): warmup, bench, incline, curl, pushdown
        let weights: [[Double?]] = [
            [10, 10],
            [60, 75, 85],
            [60, 60, 60],
            [15, 15, 12],
            [20, 20, 17.5]
        ]
        // Peak / avg acceleration per exercise (g) — heavier lifts are faster
        let accelData: [[(Double, Double)]] = [
            [(0.6, 0.3), (0.7, 0.35)],
            [(1.4, 0.7), (1.6, 0.8), (1.9, 0.95)],
            [(1.2, 0.6), (1.3, 0.65), (1.1, 0.55)],
            [(1.0, 0.5), (1.1, 0.55), (0.9, 0.45)],
            [(0.8, 0.4), (0.9, 0.45), (0.7, 0.35)]
        ]

        let sessionDates: [TimeInterval] = [-14 * 86400, -7 * 86400, -2 * 86400]
        let durations: [TimeInterval] = [52 * 60, 48 * 60, 55 * 60]

        for (si, offset) in sessionDates.enumerated() {
            let start = Date(timeIntervalSinceNow: offset)
            let end = start.addingTimeInterval(durations[si])
            let session = SessionModel(workoutSyncId: workout.syncId, startDate: start, endDate: end)
            var elapsed: TimeInterval = 0

            for (ei, sets) in exerciseSets.enumerated() {
                let wList = ei < weights.count ? weights[ei] : []
                let aList = ei < accelData.count ? accelData[ei] : []
                for (setIdx, setModel) in sets.enumerated() {
                    elapsed += 35
                    let weight: Double? = setIdx < wList.count ? wList[setIdx] : nil
                    let (peak, avg) = setIdx < aList.count ? aList[setIdx] : (0.0, 0.0)
                    // Add slight variation between sessions
                    let variation = Double(si) * 0.05
                    let log = SetLogModel(
                        exerciseSetId: setModel.syncId,
                        setNumber: setIdx + 1,
                        weightKg: weight,
                        peakAccelerationG: peak + variation,
                        averageAccelerationG: avg + variation,
                        completedAt: start.addingTimeInterval(elapsed)
                    )
                    session.setLogs.append(log)
                    elapsed += 90 // rest
                }
            }
            modelContext.insert(session)
        }
    }
    #endif
}

// MARK: - Workout Row

private struct WorkoutRowView: View {
    let workout: WorkoutModel

    var totalSets: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.blue)
                    .imageScale(.medium)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(workout.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text("\(workout.exercises.count) exercise\(workout.exercises.count == 1 ? "" : "s")")
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("\(totalSets) sets")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if workout.trackWeights {
                Image(systemName: "scalemass.fill")
                    .imageScale(.small)
                    .foregroundStyle(.blue.opacity(0.6))
            }
            if workout.trackAcceleration {
                Image(systemName: "bolt.fill")
                    .imageScale(.small)
                    .foregroundStyle(.orange.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}
