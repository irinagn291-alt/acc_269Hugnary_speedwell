import Foundation

struct WellLoad: Sendable, Equatable {
    var document: WellDocument
    var recoveredFromBackup: Bool
    var startedEmpty: Bool
}

protocol WellProjecting: Sendable {
    func load() async -> WellLoad
    func save(_ document: WellDocument) async
    func wipe() async
    func demoPlanted() async -> Bool
    func markDemoPlanted() async
}

enum WellDefaultsSource: Sendable {
    case standard
    case suite(String)
}

enum WellKey {
    static let snapshot = "spw.store.v1"
    static let backup = "spw.store.v1.backup"
    static let demo = "spw.demo.v1"
}

/// Role: Projects WellDocument to UserDefaults (spw.store.v1) and an atomic Application Support file. Views never touch this type.
actor WellVault: WellProjecting {
    private let source: WellDefaultsSource
    private let folder: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(source: WellDefaultsSource = .standard, folder: URL) {
        self.source = source
        self.folder = folder
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    func load() async -> WellLoad {
        let fm = FileManager.default
        if !fm.fileExists(atPath: folder.path) {
            try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        if let document = decode(defaults().data(forKey: WellKey.snapshot)) {
            return WellLoad(document: document, recoveredFromBackup: false, startedEmpty: false)
        }
        if let document = decode(defaults().data(forKey: WellKey.backup)) {
            return WellLoad(document: document, recoveredFromBackup: true, startedEmpty: false)
        }
        if let document = decode(try? Data(contentsOf: fileURL)) {
            return WellLoad(document: document, recoveredFromBackup: false, startedEmpty: false)
        }
        if let document = decode(try? Data(contentsOf: backupFileURL)) {
            return WellLoad(document: document, recoveredFromBackup: true, startedEmpty: false)
        }
        return WellLoad(document: .empty, recoveredFromBackup: false, startedEmpty: true)
    }

    func save(_ document: WellDocument) async {
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            return
        }
        var snapshot = document
        snapshot.schemaVersion = WellDocument.currentSchema
        guard let data = try? encoder.encode(snapshot) else { return }
        let box = defaults()
        if let current = box.data(forKey: WellKey.snapshot) {
            box.set(current, forKey: WellKey.backup)
        }
        if fm.fileExists(atPath: fileURL.path) {
            try? fm.removeItem(at: backupFileURL)
            try? fm.copyItem(at: fileURL, to: backupFileURL)
        }
        box.set(data, forKey: WellKey.snapshot)
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            return
        }
    }

    func wipe() async {
        let box = defaults()
        box.removeObject(forKey: WellKey.snapshot)
        box.removeObject(forKey: WellKey.backup)
        let fm = FileManager.default
        try? fm.removeItem(at: fileURL)
        try? fm.removeItem(at: backupFileURL)
    }

    func demoPlanted() async -> Bool {
        defaults().bool(forKey: WellKey.demo)
    }

    func markDemoPlanted() async {
        defaults().set(true, forKey: WellKey.demo)
    }

    private func decode(_ data: Data?) -> WellDocument? {
        guard let data else { return nil }
        return try? decoder.decode(WellDocument.self, from: data)
    }

    private var fileURL: URL {
        folder.appendingPathComponent("well.json", isDirectory: false)
    }

    private var backupFileURL: URL {
        folder.appendingPathComponent("well.json.backup", isDirectory: false)
    }

    private func defaults() -> UserDefaults {
        switch source {
        case .standard:
            return .standard
        case .suite(let name):
            return UserDefaults(suiteName: name) ?? .standard
        }
    }
}

actor MemoryVault: WellProjecting {
    private var document: WellDocument
    private var planted: Bool

    init(document: WellDocument = .empty, planted: Bool = false) {
        self.document = document
        self.planted = planted
    }

    func load() async -> WellLoad {
        WellLoad(
            document: document,
            recoveredFromBackup: false,
            startedEmpty: document.bottles.isEmpty
        )
    }

    func save(_ document: WellDocument) async {
        self.document = document
    }

    func wipe() async {
        document = .empty
    }

    func demoPlanted() async -> Bool { planted }

    func markDemoPlanted() async { planted = true }
}
