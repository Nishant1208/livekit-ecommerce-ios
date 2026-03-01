//
//  SceneDelegate.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let landingVC = LandingViewController(nibName: "LandingViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: landingVC)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }
}
