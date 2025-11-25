//
//  Device+Mapping.swift
//  NetScope
//
//  Created by Claude Code
//

import Foundation
import CoreData

extension Device {
    /// Полиморфная конвертация Device → DeviceModel
    /// Определяет тип устройства и вызывает соответствующий метод toModel()
    func toModel() -> DeviceModel? {
        // Проверка типа entity через приведение типа
        if let btDevice = self as? BluetoothDevice {
            return .bluetooth(btDevice.toModel())
        } else if let lanDevice = self as? LANDevice {
            return .lan(lanDevice.toModel())
        }

        // Если тип не определен, возвращаем nil
        return nil
    }
}
