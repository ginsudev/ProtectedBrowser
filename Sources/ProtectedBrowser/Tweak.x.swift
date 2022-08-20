import Orion
import ProtectedBrowserC

struct tweak: HookGroup {}

class WKUserContentController_Hook: ClassHook<WKUserContentController> {
    typealias Group = tweak

    func addUserScript(_ script: WKUserScript) {
        target.removeAllUserScripts()
        return
    }
}

class WKWebViewConfiguration_Hook: ClassHook<WKWebViewConfiguration> {
    typealias Group = tweak

    func _allowsJavaScriptMarkup() -> Bool {
        return false
    }
}

struct ProtectedBrowser: Tweak {
    init() {
        guard Bundle.main.bundleIdentifier != "com.apple.mobilesafari" else {
            return
        }

        tweak().activate()
    }
}
