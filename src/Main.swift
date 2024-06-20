import AppKit

func bundleIdentifier(for url: URL) -> String? {
    guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: url),
          let bundle = Bundle(url: appURL)
    else {
        return nil
    }
    return bundle.bundleIdentifier
}

func getDefaultBrowser() -> String? {
    let httpURL = URL(string: "http://")!
    guard let appURL = LSCopyDefaultApplicationURLForURL(httpURL as CFURL, .all, nil)?.takeRetainedValue() as URL? else {
        return nil
    }
    return bundleIdentifier(for: appURL)
}

func setDefaultBrowser(_ id: String) {
    LSSetDefaultHandlerForURLScheme("http" as CFString, id as CFString)
}

func getBrowsers() -> [String] {
    let httpURL = URL(string: "http://")!
    let urls = LSCopyApplicationURLsForURL(httpURL as CFURL, .all)?.takeRetainedValue() as? [URL] ?? []
    return urls.compactMap { bundleIdentifier(for: $0) }
}

func printHelp() {
    print("""
    Usage: defaultb [-l|-s <bundle_id>|-g|-h]

    Options:
        -h, --help                   Print this help message
        -l, --list                   List the available browsers
        -s, --set <bundle_id>        Set the default browser to the given bundle ID
        -g, --get                    Get the default browser
    """)
}

let args = CommandLine.arguments.dropFirst()

guard let option = args.first else {
    print("Error: missing argument")
    printHelp()
    exit(1)
}

switch option {
case "-l", "--list":
    let browsers = getBrowsers()
    if browsers.isEmpty {
        print("No browsers found.")
    } else {
        for browser in browsers {
            print(browser)
        }
    }

case "-s", "--set":
    guard let bundleID = args.dropFirst().first else {
        print("Error: missing bundle id argument")
        printHelp()
        exit(1)
    }
    if getDefaultBrowser() == bundleID {
        print("Browser is already set to \(bundleID)")
    } else {
        setDefaultBrowser(bundleID)
        print("Set default browser to \(bundleID)")
    }

case "-g", "--get":
    if let defaultBrowser = getDefaultBrowser() {
        print("Default browser: \(defaultBrowser)")
    } else {
        print("Could not determine the default browser.")
    }

case "-h", "--help":
    printHelp()

default:
    print("Error: invalid argument")
    printHelp()
    exit(1)
}
