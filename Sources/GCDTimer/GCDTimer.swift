import Foundation

/// Simple encapsulation of DispatchSourceTimer
/// for timing, countdown, and delayed execution
open class GCDTimer {
    
    /// Initialization method
    ///
    /// - Parameter queue: DispatchQueue
    /// DispatchQueue default main queue
    ///
    /// - Exmple
    ///  ```
    ///     let timer = GCDTimer(.global())
    ///  ```
    public init(_ queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    /// The current object's queue
    private var queue: DispatchQueue
    
    /// Prevent multiple executions of `suspend` operations
    private var suspend = 0
    
    
    /// Lazy loading creates `DispatchSourceTimer`
    private lazy var timer: DispatchSourceTimer = {
        return DispatchSource.makeTimerSource(flags: [], queue: self.queue)
    }()
    
    /// Total countdown
    private var count: Double = 0
}

/// Timer
extension GCDTimer {
    
    /// Start, execute automatically
    ///
    /// - Parameters:
    ///   - timeInterval: Int
    ///   - handler: Handler
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.start(1) {
                // code
    ///     }
    /// ```
    open func start(_ timeInterval: Int, handler: @escaping () -> Void) {
        self.timer.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.seconds(timeInterval))
        self.timer.setEventHandler {
            handler()
        }
        self.timer.resume()
    }
    
    /// Start, execute automatically
    ///
    /// - Parameters:
    ///   - timeInterval: TimeInterval
    ///   - handler: Handler
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.start(1.0) {
                // code
    ///     }
    /// ```
    open func start(_ timeInterval: TimeInterval, handler: @escaping () -> Void) {
        self.timer.schedule(deadline: .now(), repeating: timeInterval)
        self.timer.setEventHandler {
            handler()
        }
        self.timer.resume()
    }
    
    /// Pause
    /// Essentially the `DispatchSourceTimer` suspend state
    /// Since Timer can perform multiple `suspend` operations,
    /// for user experience, only one `suspend` operation
    /// is limited.
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.start(1.0) {
    ///         // code
    ///     }
    ///     timer.pause()
    /// ```
    open func pause() {
        guard !self.timer.isCancelled else {
            return
        }
        if suspend == 0 {
            self.timer.suspend()
            suspend = 1
        }
    }
    
    /// Restart
    /// To restart after a pause
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.start(1) {
    ///         // code
    ///     }
    ///     timer.pause()
    ///     timer.restart()
    /// ```
    open func restart() {
        guard !self.timer.isCancelled else {
            return
        }
        if suspend == 1 {
            self.timer.resume()
            suspend = 0
        }
    }
    
    /// Stop
    /// stop timer
    /// This method can stop the `countdown` operation
    /// when the `countdown` is not completed.
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.start(1) {
    ///         // code
    ///     }
    ///     timer.stop()
    /// ```
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.countdown(60, repeating: 2) {
    ///         // code
    ///     }
    ///     timer.stop()
    /// ```
    open func stop() {
        self.timer.cancel()
    }
}

/// countdown
extension GCDTimer {
    
    /// countdown
    /// - Parameters:
    ///   - countdown: Total countdown time
    ///   - repeating: How often to execute (unit: seconds)
    ///   - handler: Handler
    ///
    /// - Exmple
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.countdown(60, 1) {
    ///         // code
    ///     }
    /// ```
    open func countdown(_ countdown: Double, repeating: Double, handler: @escaping () -> Void) {
        self.count = countdown
        self.timer.schedule(deadline: DispatchTime.now(), repeating: repeating)
        self.timer.setEventHandler { [weak self] in
            self?.count -= repeating
            if self?.count ?? 0 <= 0 {
                self?.timer.cancel()
            }
            handler()
        }
        self.timer.resume()
    }
}

/// Delay operation
extension GCDTimer {
    
    /// Execute after a few seconds
    /// - Parameters:
    ///   - deadline: TimeInterval
    ///   - handler: Handler
    ///
    /// - Exmple (Execute after 1 second)
    /// ```
    ///     let timer = GCDTimer()
    ///     timer.after(1) {
    ///         // code
    ///     }
    /// ```
    open func after(_ deadline: TimeInterval, handler: @escaping () -> Void) {
        self.queue.asyncAfter(deadline: .now() + deadline) {
            handler()
        }
    }
}
