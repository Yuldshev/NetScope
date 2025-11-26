import Foundation

// MARK: - Handle Error
enum ScanError: LocalizedError {
  case bluetoothUnavailable
  case bluetoothUnauthorized
  case bluetoothPoweredOff
  case networkUnavailable
  case scanTimeout
  case scanAlreadyInProgress
  case scanFailed(String)
  
  var errorDescription: String? {
    switch self {
    case .bluetoothUnavailable:
      return "Bluetooth недоступен на этом устройстве"
    case .bluetoothUnauthorized:
      return "Нет разрешения на использование Bluetooth. Разрешите доступ в Настройках"
    case .bluetoothPoweredOff:
      return "Bluetooth выключен. Включите Bluetooth для сканирования"
    case .networkUnavailable:
      return "Сеть недоступна для сканирования"
    case .scanTimeout:
      return "Время сканирования истекло (15 секунд)"
    case .scanAlreadyInProgress:
      return "Сканирование уже выполняется"
    case .scanFailed(let reason):
      return "Ошибка сканирования: \(reason)"
    }
  }
}

// MARK: - Base service protocol
protocol ScanServiceProtocol {
  func startScan(timeout: TimeInterval) async throws -> [DeviceModel]
  func stopScan()
}
