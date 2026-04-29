import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let eventTapController = EventTapController()
    private var modeItems: [NSMenuItem] = []

    // MARK: - App lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as a menu-bar-only app (no Dock icon, no app menu bar)
        NSApp.setActivationPolicy(.accessory)
        requestAccessibilityIfNeeded()
        buildMenuBar()
    }

    // MARK: - Accessibility

    private func requestAccessibilityIfNeeded() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        guard !AXIsProcessTrustedWithOptions(opts) else { return }

        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
            KeyBender needs Accessibility access to intercept and \
            replace keystrokes system-wide.

            Open System Settings → Privacy & Security → Accessibility, \
            add this app, then relaunch it.
            """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Menu bar

    private func buildMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = TranslationMode.off.statusBarLabel

        let menu = NSMenu()

        let header = NSMenuItem(title: "KeyBender", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        for mode in TranslationMode.allCases {
            let item = NSMenuItem(
                title: mode.menuLabel,
                action: #selector(selectMode(_:)),
                keyEquivalent: mode.keyEquivalent
            )
            item.keyEquivalentModifierMask = [.command, .shift]
            item.representedObject = mode
            item.target = self
            item.state = (mode == .off) ? .on : .off
            modeItems.append(item)
            menu.addItem(item)
        }

        menu.addItem(.separator())

        // Live preview line – updated whenever a mode is selected
        let previewItem = NSMenuItem(title: "Example 'A': —", action: nil, keyEquivalent: "")
        previewItem.isEnabled = false
        previewItem.tag = 1
        menu.addItem(previewItem)

        menu.addItem(.separator())
        menu.addItem(
            NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        )

        statusItem.menu = menu
    }

    // MARK: - Mode selection

    @objc private func selectMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? TranslationMode else { return }

        eventTapController.currentMode = mode

        for item in modeItems {
            item.state = (item.representedObject as? TranslationMode == mode) ? .on : .off
        }

        statusItem.button?.title = mode.statusBarLabel

        if let preview = statusItem.menu?.item(withTag: 1) {
            let example = mode.encode(Character("A")) ?? "A"
            preview.title = "Example 'A': \(example)"
        }
    }
}
