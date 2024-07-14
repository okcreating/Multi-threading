import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

var storage = [Chip]()
var mutex = NSCondition()
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
        // var counter = 0

        for counter in 1...10 {
            mutex.lock()
            var timer = Timer(timeInterval: 1, repeats: false) { timer in

                storage.append(Chip.make())
                print("Instance \(counter) added to the storage.")
                mutex.unlock()
                //counter += 1
                //if counter == 10 {
                //    timer.invalidate()

            }

            RunLoop.current.add(timer, forMode: .common)
           RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 2))
        }
    }
}

class WorkingThread: Thread {
    func workWithChip() {

        while (!isStorageEmpty) {
            mutex.lock()
            print(storage)
            var instance = storage.removeLast()
            instance.soldering()
            print("Chip is soldered.")
            mutex.unlock()
        }
    }
}

var generationQueue = GenerationThread()
var workingQueue = WorkingThread()

generationQueue.generateInstances()
workingQueue.workWithChip()

