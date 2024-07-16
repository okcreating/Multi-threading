import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        return Chip(chipType: chipType)
    }

    public func soldering() {
        let solderingTime = chipType.rawValue
        sleep(UInt32(solderingTime))
    }
}

class ThreadSafeWorkout {
    private var storage = [Chip]()
    var mutex = NSCondition()
    var isThreadAvailable = false
    var isStorageEmpty: Bool {
        storage.isEmpty
    }

    func addElement(element: Chip) {
        mutex.lock()
        isThreadAvailable = true
        storage.append(element)
        mutex.signal()
        mutex.unlock()
    }

    func removeElement() -> Chip {
        mutex.lock()
        while (!isThreadAvailable) {
            mutex.wait()
        }
        isThreadAvailable = false
        mutex.unlock()
        return storage.removeLast()
    }
}

class GenerationThread: Thread {
    private var storage: ThreadSafeWorkout
    private var timer = Timer()
    var counter = 0

    init(storage: ThreadSafeWorkout) {
        self.storage = storage
    }

    override func main() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(generateInstances), userInfo: nil, repeats: true)

        RunLoop.current.add(timer, forMode: .common)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 20))
        do {
            storage.mutex.signal()
            storage.mutex.unlock()
        }
    }

    @objc
    func generateInstances() {
        storage.addElement(element: Chip.make())
        counter += 1
        print("Chip \(counter) is added")
        }
    }

class WorkingThread: Thread {
    private let storage: ThreadSafeWorkout
    var counter = 0

    init(storage: ThreadSafeWorkout) {
        self.storage = storage
    }

    override func main() {
                storage.isStorageEmpty
                        repeat {
                            storage.removeElement().soldering()
                            counter += 1
                            print("Chip \(counter) is soldered")
                        }
        while storage.isStorageEmpty
                || storage.isThreadAvailable
    }
}

let storage = ThreadSafeWorkout()
var generationQueue = GenerationThread(storage: storage)
var workingQueue = WorkingThread(storage: storage)

generationQueue.start()
workingQueue.start()




