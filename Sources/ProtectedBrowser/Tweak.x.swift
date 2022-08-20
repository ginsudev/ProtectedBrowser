import Orion
import WebKit
import ProtectedBrowserC

struct Settings {
    static var isEnabled: Bool!
    static var overkillMode: Bool!
    static var monitor: Bool!
    static var enabledApps: [String]!
}

struct tweak: HookGroup {}
struct overkillMode: HookGroup {}
struct monitor: HookGroup {}

//MARK: - External JS detection.
class WKWebView_Hook: ClassHook<WKWebView> {
    typealias Group = monitor
    
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
class WKUserContentController_Hook: ClassHook<WKUserContentController> {
    typealias Group = tweak

    func addUserScript(_ script: WKUserScript) {
        target.removeAllUserScripts()
        return
    }
}

//MARK: - Overkill
class WKWebViewConfiguration_Hook: ClassHook<WKWebViewConfiguration> {
    typealias Group = overkillMode

    func _allowsJavaScriptMarkup() -> Bool {
        return false
    }
}

//MARK: - Preferences
fileprivate func prefsDict() -> [String : AnyObject]? {
    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
    
    let path = "/var/mobile/Library/Preferences/com.ginsu.protectedbrowser.plist"
    
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
    Settings.overkillMode = dict["overkillMode"] as? Bool ?? false
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
                        
            if Settings.enabledApps.contains(identifier) {
                tweak().activate()

                if Settings.overkillMode {
                    overkillMode().activate()
                }
            } else {
                guard identifier != "com.apple.springboard" else {
                    return
                }
                
                if Settings.monitor {
                    monitor().activate()
                }
            }
        }
    }
}
