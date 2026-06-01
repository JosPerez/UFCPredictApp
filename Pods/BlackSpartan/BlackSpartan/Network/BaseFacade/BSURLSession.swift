//
//  BSURLSession.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation
/// Delegado de recibir la información.
public protocol BSConnectionDelegate {
    /// Recibe información correcta
    ///  - Parameters:
    ///   - data: Data de servicio
    ///   - requestName: Nombre del servicio
    func recievedData(data: Data, requestName: String)
    /// Recibe el error de servicio
    ///  - Parameters:
    ///   - Error: Error del servicio
    ///   - code: Error HTTP
    ///   - requestName: Nombre del servicio
    func recievedError(error: Error ,code: Int?, requestName: String)
}
/// Enumerador encargado revisar respuesta de servicio
enum BSResponeCode {
    /// Caso respuesta Exitosa,
    case success
    /// Caso respuesta Fallida con código,
    case failed(code: Int)
    public init(rawValue: Int) {
        if (200...299).contains(rawValue) {
            self = .success
        } else {
            self = .failed(code: rawValue)
        }
    }
}
/// Clase que hace manejo de  sesión
final public class BSURLSession: NSObject {
    /// Tiempo limite de cada petición
    internal let TIMEOUT = 15.0
    /// Delegado de envio de infromación
    public var delegate: BSConnectionDelegate?
    /// Manegador de la sesión
    private var manager: URLSession?
    /// Inicializador
    public override init() {
        super.init()
        self.manager = URLSession(configuration: loadConfiguration(), delegate: self, delegateQueue: nil)
    }
    /// Configura la sesión url
    ///  - Returns: Configuración de sesión.
    private func loadConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = TIMEOUT
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }
    /// Función que inicia petición a un servicio web.
    ///  - Parameters:
    ///   - request: Data de servicio
    ///   - requestName: Nombre del servicio
    public func sendRequest(request: URLRequest, requestName: String) {
        if !BSNetworkManager.shared.networkStatus() {
            self.delegate?.recievedError(error: BSFacadeError.notInternetConnection, code: 998, requestName: requestName)
            return
        }
        self.manager?.dataTask(with: request, completionHandler: { (data, response, error) in
            if let responseServer = response as? HTTPURLResponse, let unwrapData = data {
                switch BSResponeCode(rawValue: responseServer.statusCode) {
                case .success:
                    self.delegate?.recievedData(data: unwrapData, requestName: requestName)
                case .failed(let code):
                    if let error = error {
                        self.delegate?.recievedError(error: error, code: code, requestName: requestName)
                    } else if code == 404 {
                        let error = BSErrorBase(message: "Servicio no encontrado", code: code)
                        self.delegate?.recievedError(error: error, code: code, requestName: requestName)
                    }
                }
            }
        }).resume()
    }
}
/// Extensión que contiene las funciones de delgado de sesión
extension BSURLSession: URLSessionDelegate {}
