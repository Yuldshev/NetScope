import SwiftUI

struct SessionDetailView: View {
  let session: ScanSessionModel
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    List {
      Section {
        InfoSectionView(title: "Дата") { Text(session.formattedDate) }
        InfoSectionView(title: "Всего устройств") { Text("\(session.devicesFound)") }
        InfoSectionView(title: "Bluetooth") { Text("\(session.bluetoothDeviceCount)") }
        InfoSectionView(title: "LAN") { Text("\(session.lanDeviceCount)") }
      } header: {
        Text("Информация о сессии")
      }
      
      Section {
        ForEach(session.devices) { device in
          DeviceRowView(device: device)
        }
      } header: {
        Text("Обнаруженные устройства")
      }
    }
    .navigationTitle("Детали сессии")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Готово") {
          dismiss()
        }
      }
    }
  }
}

// MARK: - Preview
#Preview {
  SessionDetailView(session: ScanSessionModel())
}
