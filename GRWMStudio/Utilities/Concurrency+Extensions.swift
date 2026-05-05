import Foundation

struct TimeoutError: LocalizedError {
    var errorDescription: String? { "Operation timed out" }
}

private final class TimeoutRaceState<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Error>?
    private var tasks: [Task<Void, Never>] = []
    private var didFinish = false
    private var pendingResult: Result<T, Error>?

    func install(continuation: CheckedContinuation<T, Error>) {
        let result: Result<T, Error>?
        lock.lock()
        if didFinish {
            result = pendingResult
        } else {
            self.continuation = continuation
            result = nil
        }
        lock.unlock()

        if let result {
            continuation.resume(with: result)
        }
    }

    func install(tasks: [Task<Void, Never>]) {
        lock.lock()
        if didFinish {
            lock.unlock()
            tasks.forEach { $0.cancel() }
        } else {
            self.tasks = tasks
            lock.unlock()
        }
    }

    func finish(with result: Result<T, Error>) {
        let continuationToResume: CheckedContinuation<T, Error>?
        let tasksToCancel: [Task<Void, Never>]

        lock.lock()
        if didFinish {
            lock.unlock()
            return
        }

        didFinish = true
        pendingResult = result
        continuationToResume = continuation
        continuation = nil
        tasksToCancel = tasks
        tasks = []
        lock.unlock()

        tasksToCancel.forEach { $0.cancel() }
        continuationToResume?.resume(with: result)
    }
}

func withTimeout<T: Sendable>(
    _ duration: Duration,
    operation: @escaping @MainActor @Sendable () async throws -> T
) async throws -> T {
    let state = TimeoutRaceState<T>()

    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            state.install(continuation: continuation)

            let operationTask = Task { @MainActor in
                do {
                    let result = try await operation()
                    state.finish(with: .success(result))
                } catch {
                    state.finish(with: .failure(error))
                }
            }
            let timeoutTask = Task {
                do {
                    try await Task.sleep(for: duration)
                    state.finish(with: .failure(TimeoutError()))
                } catch {
                    state.finish(with: .failure(error))
                }
            }

            state.install(tasks: [operationTask, timeoutTask])
        }
    } onCancel: {
        state.finish(with: .failure(CancellationError()))
    }
}
