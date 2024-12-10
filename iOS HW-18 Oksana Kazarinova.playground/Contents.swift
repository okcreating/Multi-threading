import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// MARK: LIFO storage

class ThreadSafeWorkout<T> {
    private var storage = [T]()
    var mutex = NSCondition()
    var isThreadAvailable = false
    var isStorageEmpty: Bool {
        storage.isEmpty
    }

    func addElement(element: T) {
        mutex.lock()
        isThreadAvailable = true
        storage.append(element)
        mutex.signal()
        mutex.unlock()
    }

    func removeElement() -> T {
        mutex.lock()
        if isStorageEmpty {
            isThreadAvailable = false
        }
        while (!isThreadAvailable) {
            mutex.wait()
        }
        mutex.unlock()
        return storage.removeLast()
    }
}

// MARK: Threads

class GenerationThread: Thread {
    private var storage: ThreadSafeWorkout<Chip>
    private var timer = Timer()
    var counter = 0

    init(storage: ThreadSafeWorkout<Chip>) {
        self.storage = storage
    }

    override func main() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(generateInstances), userInfo: nil, repeats: true)

        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 20))
    }

    @objc
    func generateInstances() {
        storage.addElement(element: Chip.make())
        counter += 1
        print("Chip \(counter) is added")
        }
    }

class WorkingThread: Thread {
    private let storage: ThreadSafeWorkout<Chip>
    var counter = 0

    init(storage: ThreadSafeWorkout<Chip>) {
        self.storage = storage
    }

    override func main() {
                storage.isStorageEmpty
                        repeat {
                            storage.removeElement().soldering()
                            counter += 1
                            print("Chip \(counter) is soldered")
                        }
        while !storage.isStorageEmpty
                || storage.isThreadAvailable
    }
}

// MARK: Launch

let storage = ThreadSafeWorkout<Chip>()
var generationQueue = GenerationThread(storage: storage)
var workingQueue = WorkingThread(storage: storage)

generationQueue.start()
workingQueue.start()




