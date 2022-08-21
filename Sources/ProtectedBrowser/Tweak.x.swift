import Orion
import WebKit
import ProtectedBrowserC

enum ProtectionMode: Int {
case onlyHarmful = 0, all = 1, forceSafari = 2
}

struct Settings {
    static var isEnabled: Bool!
    static var protectionMode: ProtectionMode!
    static var monitor: Bool!
    static var enabledApps: [String]!
}

struct ExternalScripts: HookGroup {}
struct AllScripts: HookGroup {}
struct ForceSafari: HookGroup {}
struct Monitor: HookGroup {}

//MARK: - Force open Safari.
class ForceSafari_Hook: ClassHook<WKWebView> {
    typealias Group = ForceSafari
    
    func _didStartProvisionalLoadForMainFrame() {
        orig._didStartProvisionalLoadForMainFrame()
        
        guard let url = target.url else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}

//MARK: - Monitoring for JS injection.
class Monitor_Hook: ClassHook<WKWebView> {
    typealias Group = Monitor
    
    func _didCommitLoadForMainFrame() {
        orig._didCommitLoadForMainFrame()
        
        let userContent = target.configuration.userContentController
        
        guard !userContent.userScripts.isEmpty else {
            return
        }
        
        guard !UserDefaults.standard.bool(forKey: "ProtectedBrowser_\(Bundle.main.bundleIdentifier!).alreadyAlerted") else {
            return
        }
        
        presentDetectedExternalJSAlert()
    }
    
    //orion: new
    func presentDetectedExternalJSAlert() {
        let alert = UIAlertController(title: "ProtectedBrowser", message: "ProtectedBrowser has detected that this app injects external JavaScript code that may be invasive/malicious.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Disable JS in this app", style: .destructive, handler: { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Don't alert me again", style: .default, handler: { action in
            UserDefaults.standard.set(true, forKey: "ProtectedBrowser_\(Bundle.main.bundleIdentifier!).alreadyAlerted")
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        target._viewControllerForAncestor().present(alert, animated: true)
    }
}

//MARK: - Removing external JS
class ExternalJS_Hook: ClassHook<WKUserContentController> {
    typealias Group = ExternalScripts

    func addUserScript(_ script: WKUserScript) {
        target.removeAllUserScripts()
        return
    }
}

//MARK: - Overkill
class AllJS_Hook: ClassHook<WKWebViewConfiguration> {
    typealias Group = AllScripts

    func _allowsJavaScriptMarkup() -> Bool {
        return false
    }
}

//MARK: - Preferences
fileprivate func prefsDict() -> [String : AnyObject]? {
    var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
    
    let path = "/var/mobile/Library/Preferences/com.ginsu.protectedbrowser-new.plist"
    
    if !FileManager().fileExists(atPath: path) {
        try? FileManager().copyItem(atPath: "Library/PreferenceBundles/protectedbrowser.bundle/defaults.plist",
                                    toPath: path)
    }
    
    let plistURL = URL(fileURLWithPath: path)

    guard let plistXML = try? Data(contentsOf: plistURL) else {
        return nil
    }
    
    guard let plistDict = try! PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String : AnyObject] else {
        return nil
    }
    
    return plistDict
}

fileprivate func readPrefs() {
    
    let dict = prefsDict() ?? [String : AnyObject]()
    
    //Reading values
    Settings.isEnabled = dict["isEnabled"] as? Bool ?? true
    Settings.protectionMode = ProtectionMode(rawValue: dict["protectionMode"] as? Int ?? 0)
    Settings.monitor = dict["monitor"] as? Bool ?? true
    Settings.enabledApps = dict["enabledApps"] as? [String] ?? [""]
}

struct ProtectedBrowser: Tweak {
    init() {
        readPrefs()
        
        if Settings.isEnabled {
            guard let identifier = Bundle.main.bundleIdentifier else {
                return
            }
            
            guard !identifier.hasPrefix("com.apple.") else {
                return
            }
            
            guard Settings.enabledApps.contains(identifier) else {
                if Settings.monitor {
                    Monitor().activate()
                }
                return
            }
            
            switch Settings.protectionMode {
            case .all:
                ExternalScripts().activate()
                AllScripts().activate()
                break
            case .onlyHarmful:
                ExternalScripts().activate()
                break
            case .forceSafari:
                ForceSafari().activate()
                break
            default:
                ExternalScripts().activate()
                break
            }

        }
    }
}
