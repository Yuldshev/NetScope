import SwiftUI

struct SessionDetailView: View {
  let session: ScanSessionModel
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    List {
      Section {
        HStack {
          Text("Дата")
          Spacer()
          Text(session.formattedDate)
            .foregroundColor(.secondary)
        }
        HStack {
          Text("Всего устройств")
          Spacer()
          Text("\(session.devicesFound)")
            .foregroundColor(.secondary)
        }
        HStack {
          Text("Bluetooth")
          Spacer()
          Text("\(session.bluetoothDeviceCount)")
            .foregroundColor(.secondary)
        }
        HStack {
          Text("LAN")
          Spacer()
          Text("\(session.lanDeviceCount)")
            .foregroundColor(.secondary)
        }
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

#Preview {
  SessionDetailView(session: ScanSessionModel())
}
