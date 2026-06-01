//
//  BSBaseFacade.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//
import Foundation

/// Delegado de recibir la información.
public protocol BSResponseDelegate {
    /// Recibe información correcta
    ///  - Parameters:
    ///   - entity: Data de servicio.
    ///   - requestName: Nombre del servicio
    func recievedEntity<T>(entity: T, requestName: String)
}
open class BSBaseFacade {
    /// URL base de servicio
    public var url: String!
    /// Connection
    public var connection: BSURLSession
    /// Delegado de la respuesta.
    public var delegate: BSResponseDelegate?
    /// Inicializador
    public init(url: String) {
        self.url = url
        self.connection = BSURLSession()
    }
    /// Recibe el  error del servicio
    ///  - Parameters:
    ///    - error: Error del servicio.
    ///    - code: Código der error del servicio.
    ///    - requestName: Nombre de la petición.
    open func recievedError(error: Error ,code: Int?, requestName: String) {
        let baseError = BSErrorBase(message: error.localizedDescription , code: code)
        self.delegate?.recievedEntity(entity: baseError, requestName: requestName)
    }
    /// Decode de la entidad de forma segura.
    ///  - Parameters:
    ///    - responseType: Tipo Entidad.
    ///    - data: data  del servicio.
    ///    - requestName: Nombre de la petición.
    public func decodeEntity<T: Codable>(responseType: T.Type, data: Data, requestName: String) {
        DispatchQueue.main.async {
            do {
                let response = try JSONDecoder().decode(responseType, from: data)
                self.delegate?.recievedEntity(entity: response, requestName: requestName)
            } catch let error {
                print(error)
                do {
                    let response = try JSONDecoder().decode(BSErrorBase.self, from: data)
                    self.delegate?.recievedEntity(entity: response, requestName: requestName)
                } catch let error {
                    print(error)
                    let baseError = BSErrorBase(message: "Problema en el decodeo", code: 999)
                    self.delegate?.recievedEntity(entity: baseError, requestName: requestName)
                }
            }
        }
    }
    /// Petición ´GET´ para consultas de usuarios .
    ///  - Parameters:
    ///    - uri: String con el uri necesitado
    ///    - isTokenSecure: En caso de requerir el token
    func getRequest(uri: String, isTokenSecure:Bool=true) throws -> URLRequest {
        let newUrl: String = url + uri
        guard let mainUrl = URL(string: newUrl) else {
            throw BSFacadeError.missingUrl
        }
        print("petición GET a: \(mainUrl)")
        var request: URLRequest = URLRequest(url: mainUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        if isTokenSecure {
            request.setValue(Keys().apiKey, forHTTPHeaderField: "X-API-Key")
        }
        return request
    }
    /// Petición ´POST´ para consultas de usuarios .
    ///  - Parameters:
    ///    - uri: String con el uri necesitado
    ///    - isTokenSecure: En caso de requerir el token
    func postRequest(uri: String, body: Data) throws -> URLRequest {
        let newUrl: String = url + uri
        guard let mainUrl = URL(string: newUrl) else {
            throw BSFacadeError.missingUrl
        }
        print("petición POST a: \(mainUrl)")
        var request = URLRequest(url: mainUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Keys().apiKey, forHTTPHeaderField: "X-API-Key")
        request.httpBody = body
        return request
    }
}
final public class BSErrorBase: Codable, Error, CustomStringConvertible {
    /// Mensaje de error
    public var message: String?
    /// Codigo de error
    public var code: Int?
    /// Inicializador con parametros
    public init(message: String?,code: Int?) {
        self.message = message
        self.code = code
    }
    enum CodingKeys: String, CodingKey {
        case message
        case code
    }
    public var description: String {
        return "message: \(String(describing: self.message)) - code: \(String(describing: self.code))"
    }
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.message = try container.decodeIfPresent(String.self, forKey: .message)
            self.code = try container.decodeIfPresent(Int.self, forKey: .code)
        } catch let error {
            print(error)
            throw BSFacadeError.baseErrorBadDecoding
        }
    }
}
/// Enumerador con errores en fachada
public enum BSFacadeError: String, Error, LocalizedError ,CustomStringConvertible {
    /// No se pudo convertir URL
    case missingUrl = "!No se encuetra URL¡"
    /// Error con la conexión a internet
    case notInternetConnection = "Error de conexión"
    /// Error con decode de entidad error
    case baseErrorBadDecoding = "Entidad de error mal decodeo"
    public var description: String {
        return "Error: " + self.rawValue
    }
}
