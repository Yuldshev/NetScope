//
//  ScanSession+Mapping.swift
//  NetScope
//
//  Created by Claude Code
//

import Foundation
import CoreData

extension ScanSession {
    /// Convert CoreData ScanSession entity to ScanSessionModel struct
    func toModel() -> ScanSessionModel {
        // Конвертация NSSet<Device> → [DeviceModel]
        let deviceModels = (self.devices as? Set<Device>)?
            .compactMap { $0.toModel() }
            .sorted { $0.discoveredAt < $1.discoveredAt } ?? []

        return ScanSessionModel(
            id: self.id ?? UUID(),
            timestamp: self.timestamp ?? Date(),
            devicesFound: Int(self.devicesFound),
            devices: deviceModels
        )
    }
}
