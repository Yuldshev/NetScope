import SwiftUI

struct DateFilterView: View {
  @ObservedObject var viewModel: HistoryViewModel
  @Environment(\.dismiss) private var dismiss
  
  @State private var startDate: Date = Date()
  @State private var endDate: Date = Date()
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          DatePicker("Начальная дата", selection: $startDate, displayedComponents: [.date])
          DatePicker("Конечная дата", selection: $endDate, displayedComponents: [.date])
        } header: {
          Text("Выберите период")
        } footer: {
          Text("Будут показаны все сессии в выбранном диапазоне дат")
        }
      }
      .navigationTitle("Фильтр по дате")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Отмена") { dismiss() }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Применить") {
            viewModel.filterStartDate = startDate
            viewModel.filterEndDate = endDate
            dismiss()
          }
        }
      }
      .onAppear {
        if let start = viewModel.filterStartDate {
          startDate = start
        }
        if let end = viewModel.filterEndDate {
          endDate = end
        }
      }
    }
  }
}

// MARK: - Preview
#Preview {
  DateFilterView(viewModel: HistoryViewModel())
}

