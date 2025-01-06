import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // A normal Bool (NOT @State) for toggling the AddExpense sheet
    private var showAddTransaction = false

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 1) Create ContentView with a Binding to showAddTransaction
        let contentView = ContentView(
            showAddTransaction: Binding(
                get: { self.showAddTransaction },
                set: { self.showAddTransaction = $0 }
            )
        )

        // 2) Set up our UIHostingController
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()

        // 3) If the app was launched via deep link, handle it right away
        if !connectionOptions.urlContexts.isEmpty {
            guard let url = connectionOptions.urlContexts.first?.url else { return }
            print("DEBUG: (willConnectTo) Received URL:", url)
            if url.scheme == "moneym8",
               url.host?.lowercased() == "addexpense" {
                print("DEBUG: Toggling showAddTransaction = true (initial launch)")
                showAddTransaction = true
            }
        }
    }

    // 4) If the app is *already running* and we get a deep link
    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        print("DEBUG: (openURLContexts) Received URL:", url)

        if url.scheme == "moneym8",
           url.host?.lowercased() == "addexpense" {
            print("DEBUG: Toggling showAddTransaction = true (running app)")
            showAddTransaction = true
        }
    }
}
