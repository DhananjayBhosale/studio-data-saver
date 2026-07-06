import Foundation

actor VideoWorkQueue {
    private var items: [PlanItem]

    init(_ items: [PlanItem]) {
        self.items = items
    }

    func next() -> PlanItem? {
        if items.isEmpty {
            nil
        } else {
            items.removeFirst()
        }
    }
}
