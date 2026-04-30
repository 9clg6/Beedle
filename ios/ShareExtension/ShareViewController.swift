//
//  ShareViewController.swift
//  ShareExtension
//
//  Point d'entrée natif iOS du partage "Envoyer vers Beedle".
//  RSIShareViewController est inclus localement (copie du plugin
//  receive_sharing_intent) — le pod ne peut pas être linké dans une
//  app extension car il utilise des APIs UIApplicationDelegate interdites.
//

import UIKit

class ShareViewController: RSIShareViewController {
    // Redirige automatiquement vers l'app hôte après réception.
    // L'app consomme les fichiers via ReceiveSharingIntent.getInitialMedia().
    override func shouldAutoRedirect() -> Bool {
        return true
    }
}
