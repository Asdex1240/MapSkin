import Observation
import Testing
@testable import CarPlayUI

@MainActor
@Observable
private final class Counter {
    var value = 0
}

@MainActor
struct ObservedValueTests {
    @Test func reportsInitialValue() {
        let counter = Counter()
        var received: [Int] = []

        let observation = ObservedValue({ counter.value }) { received.append($0) }

        #expect(received == [0])
        observation.cancel()
    }

    @Test func reportsChanges() async {
        let counter = Counter()
        var received: [Int] = []
        let observation = ObservedValue({ counter.value }) { received.append($0) }

        counter.value = 3
        await Task.yield()
        await Task.yield()

        #expect(received == [0, 3])
        observation.cancel()
    }

    @Test func stopsReportingAfterCancel() async {
        let counter = Counter()
        var received: [Int] = []
        let observation = ObservedValue({ counter.value }) { received.append($0) }

        observation.cancel()
        counter.value = 5
        await Task.yield()
        await Task.yield()

        #expect(received == [0])
    }
}
