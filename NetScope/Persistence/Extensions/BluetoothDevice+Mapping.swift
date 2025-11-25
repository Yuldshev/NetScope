//
//  BluetoothDevice+Mapping.swift
//  NetScope
//
//  Created by Claude Code
//

import Foundation
import CoreData

extension BluetoothDevice {
    /// Convert CoreData BluetoothDevice entity to BluetoothDeviceModel struct
    func toModel() -> BluetoothDeviceModel {
        return BluetoothDeviceModel(
            id: self.id ?? UUID(),
            name: self.name,
            discoveredAt: self.discoveredAt ?? Date(),
            uuid: self.uuid ?? "",
            rssi: Int(self.rssi),
            connectionStatus: BluetoothConnectionStatus(rawValue: self.connectionStatus ?? "") ?? .disconnected
        )
    }
}
