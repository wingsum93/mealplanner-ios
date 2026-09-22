//
//  MealScheduler.swift
//  Meal Planner
//
//  Deterministic meal allocation with an injectable RNG (FR-3.3, FR-4.2,
//  NFR "deterministic tests").
//

import Foundation

/// Simple xorshift generator so unit tests can seed the scheduler.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

struct MealScheduler {
    private var generator: any RandomNumberGenerator

    init(generator: any RandomNumberGenerator = SystemRandomNumberGenerator()) {
        self.generator = generator
    }

    static func ordered(_ timeboxes: Set<PlanTimebox>) -> [PlanTimebox] {
        PlanTimebox.allCases.filter(timeboxes.contains)
    }

    /// Allocates meals across every (day × timebox) slot. Repeats are allowed
    /// when there are fewer meals than slots; excess meals are unused. When
    /// possible, the same meal is avoided in both slots of a single day.
    mutating func allocate(
        meals: [Int64],
        dates: [Date],
        timeboxes: [PlanTimebox]
    ) -> [PlanSlot] {
        let pool = Array(Set(meals))
        guard !pool.isEmpty, !dates.isEmpty, !timeboxes.isEmpty else { return [] }

        let shuffled = shuffled(pool)
        var result: [PlanSlot] = []
        var cursor = 0

        for date in dates {
            var usedToday: Set<Int64> = []
            for timebox in timeboxes {
                var chosen = shuffled[cursor % shuffled.count]
                cursor += 1

                if usedToday.contains(chosen), pool.count >= timeboxes.count {
                    for offset in 0..<pool.count {
                        let candidate = shuffled[(cursor + offset) % shuffled.count]
                        if !usedToday.contains(candidate) {
                            chosen = candidate
                            cursor += offset + 1
                            break
                        }
                    }
                }

                usedToday.insert(chosen)
                result.append(
                    PlanSlot(
                        date: date,
                        timebox: timebox,
                        mealId: chosen,
                        displayOrder: result.count
                    )
                )
            }
        }
        return result
    }

    /// Re-randomizes the allocation of the given meals (FR-4.2 "Shuffle all").
    mutating func shuffle(
        slots: [PlanSlot],
        meals: [Int64]
    ) -> [PlanSlot] {
        let dates = slots.map(\.date).uniqueStable()
        let timeboxes = slots.map(\.timebox).uniqueStable()
        return allocate(meals: meals, dates: dates, timeboxes: timeboxes)
    }

    private mutating func shuffled(_ items: [Int64]) -> [Int64] {
        var result = items
        guard result.count > 1 else { return result }
        for index in stride(from: result.count - 1, to: 0, by: -1) {
            let pick = Int(generator.next() % UInt64(index + 1))
            result.swapAt(index, pick)
        }
        return result
    }
}

private extension Array where Element: Hashable {
    func uniqueStable() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}