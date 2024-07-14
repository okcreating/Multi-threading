import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

var storage = [Chip]()
var mutex = NSLock()
var isStorageEmpty: Bool {
    storage.isEmpty
}

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
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

class GenerationThread: Thread {
    func generateInstances() {
        var counter = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                mutex.lock()
                storage.append(Chip.make())
                counter += 1
                print("Instance \(counter) added to the storage.")
                mutex.unlock()

                if counter == 10 {
                   timer.invalidate()
            }
        }
        RunLoop.main.add(timer, forMode: .default)
        RunLoop.main.run(until: Date.init(timeIntervalSinceNow: 0))
        }
    }

class WorkingThread: Thread {
    func workWithChip() {
        var counter = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            while (!isStorageEmpty) {
                mutex.lock()
                print(storage)
                var instance = storage.removeLast()
                instance.soldering()
                counter += 1
                print("Chip \(counter) is soldered.")
                mutex.unlock()
            }
            RunLoop.current.add(timer, forMode: .default)
            RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 0))
        }
    }
}

var generationQueue = GenerationThread()
var workingQueue = WorkingThread()

generationQueue.generateInstances()
workingQueue.workWithChip()

