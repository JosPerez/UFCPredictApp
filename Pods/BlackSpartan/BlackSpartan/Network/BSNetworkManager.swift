//
//  BSNetworkManager.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation
import Network
public protocol BSNetworkManagerDelegate {
    /// Función con el cambio de status en la red
    func didNetworkChange(status: Bool)
}
final public class BSNetworkManager: NSObject {
    /// Contiene el monitor de red.
    static public var shared: BSNetworkManager = BSNetworkManager()
    /// Fila despachadora en backfground
    private var queue: DispatchQueue
    /// Monitor de red.
    private var mainMonitor: NWPathMonitor?
    /// Contiene variable si es conectado a internet.
    private var isInternetAvailable: Bool
    /// Delegado de cambio de red
    public var networkDelegate: BSNetworkManagerDelegate?
    /// Iniicalizador
    override init() {
        self.queue = DispatchQueue.global(qos: .background)
        self.isInternetAvailable = false
        super.init()
    }
    /// Iniciar monitoreo de red
    public func start() {
        self.mainMonitor = NWPathMonitor()
        startMainMonitoring()
    }
    /// Revisar red.
    private func startMainMonitoring() {
        mainMonitor?.start(queue: queue)
        mainMonitor?.pathUpdateHandler = { path in
            self.isInternetAvailable = path.status == .satisfied
            self.networkDelegate?.didNetworkChange(status: self.networkStatus())
        }
    }
    /// Estatus de red.
    /// - Returns: Valor si esta encendida.
    public func networkStatus() -> Bool {
        return isInternetAvailable
    }
    /// Termina monitoreo de red
    public func cancel() {
        mainMonitor?.cancel()
        self.isInternetAvailable = false
        mainMonitor = nil
    }
}
