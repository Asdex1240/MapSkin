import Observation

@MainActor
protocol ObservationCancelling: AnyObject {
    func cancel()
}

@MainActor
final class ObservedValue<Value: Equatable>: ObservationCancelling {
    private let read: @MainActor () -> Value
    private let onChange: @MainActor (Value) -> Void
    private var lastValue: Value?
    private var isActive = true

    init(_ read: @escaping @MainActor () -> Value, onChange: @escaping @MainActor (Value) -> Void) {
        self.read = read
        self.onChange = onChange
        track()
    }

    func cancel() {
        isActive = false
    }

    private func track() {
        guard isActive else { return }
        let value = withObservationTracking {
            read()
        } onChange: { [weak self] in
            Task { @MainActor in self?.track() }
        }
        guard value != lastValue else { return }
        lastValue = value
        onChange(value)
    }
}
