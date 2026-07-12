//
//  API Key.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

/// Configuración pública del pod. El consumidor debe setear `apiKey` una vez
/// al arranque de la app (ej. en `@main App.init` o `AppDelegate`).
/// El valor nunca se compila en el pod.
public enum BlackSpartanConfig {
    public static var apiKey: String = ""
}
