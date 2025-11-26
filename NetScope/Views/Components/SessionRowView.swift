import SwiftUI

struct SessionRowView: View {
  let session: ScanSessionModel
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(session.formattedDate)
          .font(.headline)
        
        HStack(spacing: 12) {
          Label("\(session.bluetoothDeviceCount)", systemImage: "antenna.radiowaves.left.and.right")
            .font(.caption)
            .foregroundStyle(.blue)
          
          Label("\(session.lanDeviceCount)", systemImage: "network")
            .font(.caption)
            .foregroundStyle(.green)
        }
      }
      Spacer()
      
      VStack(alignment: .trailing, spacing: 4) {
        Text("\(session.devicesFound)")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.primary)
        
        Text("устройств")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, 8)
  }
}

#Preview {
  SessionRowView(session: ScanSessionModel())
}
