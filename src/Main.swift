import AppKit

struct Browser: Codable {
    let name, path, bundleIdentifier: String
}

func bundleIdentifier(for url: URL) -> String? {
    guard let appURL = NSWorkspace.shared.urlForApplication(toOpen: url),
          let bundle = Bundle(url: appURL)
    else {
        return nil
    }
    return bundle.bundleIdentifier
}

func getAppInfo(bundleIdentifier: String) -> Browser? {
    let workspace = NSWorkspace.shared
    if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
        let appPath = appURL.path
        let appName = Bundle(url: appURL)?.infoDictionary?["CFBundleName"] as? String ?? ""
        return Browser(name: appName, path: appPath, bundleIdentifier: bundleIdentifier)
    }
    return nil
}

func getDefaultBrowser() -> String? {
    let httpURL = URL(string: "http://")!
    guard let appURL = LSCopyDefaultApplicationURLForURL(httpURL as CFURL, .all, nil)?.takeRetainedValue() as URL? else {
        return nil
    }
    return bundleIdentifier(for: appURL)
}

func setDefaultBrowser(_ bundleIdentifier: String) {
    LSSetDefaultHandlerForURLScheme("http" as CFString, bundleIdentifier as CFString)
}

func getBrowsers() -> [Browser] {
    let httpURL = URL(string: "http://")!
    let urls = LSCopyApplicationURLsForURL(httpURL as CFURL, .all)?.takeRetainedValue() as? [URL] ?? []
    return urls.compactMap {
        if let bundleIdentifier = bundleIdentifier(for: $0) {
            return getAppInfo(bundleIdentifier: bundleIdentifier)
        }
        return nil
    }
}

func printHelp() {
    print("""
    Usage: defaultb [-l|-s <bundle_id>|-g|-h]

    Options:
        -h, --help                   Print this help message
        -l, --list                   List the available browsers
        -j, --json                   List the available browsers as JSON
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
            print(browser.bundleIdentifier)
        }
    }

case "-j", "--json":
    let browsers = getBrowsers()
    if browsers.isEmpty {
        print("No browsers found.")
    } else {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(browsers)
        print(String(data: data, encoding: .utf8)!)
    }

case "-s", "--set":
    guard let bundleIdentifier = args.dropFirst().first else {
        print("Error: missing bundle id argument")
        printHelp()
        exit(1)
    }
    if getDefaultBrowser() == bundleIdentifier {
        print("Browser is already set to \(bundleIdentifier)")
    } else {
        setDefaultBrowser(bundleIdentifier)
        print("Set default browser to \(bundleIdentifier)")
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
