//
//  LANDevice+Mapping.swift
//  NetScope
//
//  Created by Claude Code
//

import Foundation
import CoreData

extension LANDevice {
    /// Convert CoreData LANDevice entity to LANDeviceModel struct
    func toModel() -> LANDeviceModel {
        return LANDeviceModel(
            id: self.id ?? UUID(),
            name: self.name,
            discoveredAt: self.discoveredAt ?? Date(),
            ipAddress: self.ipAddress ?? "",
            macAddress: self.macAddress,
            hostName: self.hostName
        )
    }
}
