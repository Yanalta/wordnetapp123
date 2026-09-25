import AppKit

private enum WordNetInstaller {
    static func install() throws -> URL {
        let fileManager = FileManager.default
        guard let source = Bundle.main.resourceURL?.appendingPathComponent("WordNet.app", isDirectory: true),
              fileManager.fileExists(atPath: source.path) else {
            throw InstallerError.applicationBundleMissing
        }

        let applications = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Applications", isDirectory: true)
        try fileManager.createDirectory(at: applications, withIntermediateDirectories: true)

        let destination = applications.appendingPathComponent("WordNet.app", isDirectory: true)
        let staging = applications.appendingPathComponent(".WordNet-\(UUID().uuidString).app", isDirectory: true)
        let backup = applications.appendingPathComponent(".WordNet-backup-\(UUID().uuidString).app", isDirectory: true)
        var movedPrevious = false

        defer {
            try? fileManager.removeItem(at: staging)
            if !movedPrevious {
                try? fileManager.removeItem(at: backup)
            }
        }

        try fileManager.copyItem(at: source, to: staging)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.moveItem(at: destination, to: backup)
            movedPrevious = true
        }

        do {
            try fileManager.moveItem(at: staging, to: destination)
        } catch {
            if movedPrevious {
                try fileManager.moveItem(at: backup, to: destination)
                movedPrevious = false
            }
            throw error
        }

        if movedPrevious {
            try fileManager.removeItem(at: backup)
            movedPrevious = false
        }
        return destination
    }

    enum InstallerError: LocalizedError {
        case applicationBundleMissing

        var errorDescription: String? {
            switch self {
            case .applicationBundleMissing:
                return "The WordNet application is missing from this installer."
            }
        }
    }
}

@MainActor
final class InstallerDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusLabel: NSTextField!
    private var installButton: NSButton!
    private var openButton: NSButton!
    private let applications = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Applications", isDirectory: true)
    private var installedApp: URL {
        applications.appendingPathComponent("WordNet.app", isDirectory: true)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        createWindow()
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 250),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "WordNet Installer"
        window.isReleasedWhenClosed = false

        let title = NSTextField(labelWithString: "Install WordNet")
        title.font = .boldSystemFont(ofSize: 24)
        title.alignment = .center

        let description = NSTextField(wrappingLabelWithString:
            "Install the WordNet dictionary and application in your user Applications folder.")
        description.alignment = .center

        statusLabel = NSTextField(wrappingLabelWithString:
            "Ready to install WordNet in ~/Applications.")
        statusLabel.alignment = .center

        installButton = NSButton(title: "Install WordNet", target: self, action: #selector(installWordNet))
        installButton.bezelStyle = .rounded
        installButton.keyEquivalent = "\r"

        openButton = NSButton(title: "Open WordNet", target: self, action: #selector(openWordNet))
        openButton.bezelStyle = .rounded
        openButton.isEnabled = FileManager.default.fileExists(atPath: installedApp.path)

        let buttons = NSStackView(views: [installButton, openButton])
        buttons.orientation = .horizontal
        buttons.alignment = .centerY
        buttons.distribution = .fillEqually
        buttons.spacing = 12

        let stack = NSStackView(views: [title, description, statusLabel, buttons])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.distribution = .fill
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false

        window.contentView = NSView()
        window.contentView?.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -32),
            stack.centerYAnchor.constraint(equalTo: window.contentView!.centerYAnchor),
            buttons.widthAnchor.constraint(equalTo: stack.widthAnchor),
            installButton.widthAnchor.constraint(equalToConstant: 180),
            title.widthAnchor.constraint(equalTo: stack.widthAnchor),
            description.widthAnchor.constraint(equalTo: stack.widthAnchor),
            statusLabel.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ])
    }

    @objc private func installWordNet() {
        installButton.isEnabled = false
        openButton.isEnabled = false
        statusLabel.stringValue = "Installing WordNet..."

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = Result { try WordNetInstaller.install() }
            DispatchQueue.main.async {
                guard let self else { return }
                self.installButton.isEnabled = true
                switch result {
                case .success(let location):
                    self.statusLabel.stringValue = "WordNet was installed in \(location.deletingLastPathComponent().path)."
                    self.openButton.isEnabled = true
                case .failure(let error):
                    self.statusLabel.stringValue = "Installation failed."
                    let alert = NSAlert(error: error)
                    alert.runModal()
                }
            }
        }
    }

    @objc private func openWordNet() {
        NSWorkspace.shared.open(installedApp)
    }
}

@main
@MainActor
struct InstallerMain {
    static func main() {
        let application = NSApplication.shared
        let delegate = InstallerDelegate()
        application.delegate = delegate
        application.setActivationPolicy(.regular)
        application.run()
    }
}
