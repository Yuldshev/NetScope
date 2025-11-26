import SwiftUI

struct HistoryView: View {
  @StateObject private var vm = HistoryViewModel()
  @State private var selectedSession: ScanSessionModel?
  @State private var showDeleteAllConfirmation = false
  @State private var showDateFilter = false
  
  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        
      }
      
      if vm.isLoading {
        ProgressView("Загрузка...")
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(12)
          .shadow(radius: 10)
      }
    }
    .navigationTitle("История сканирования")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Button { showDateFilter.toggle() } label: {
            Label("Фильтр по дате", systemImage: "calendar")
          }
          
          if vm.isFilteringActive {
            Button { vm.clearFilter() } label: {
              Label("Сбросить фильтр", systemImage: "xmark.circle")
            }
          }
          
          Divider()
          
          Button { showDeleteAllConfirmation.toggle() } label: {
            Label("Удалить всё", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
    .sheet(isPresented: $showDateFilter) {
      DateFilterView(viewModel: vm)
    }
    .alert(item: $vm.alertConfig) { config in
      Alert(title: Text(config.title), message: Text(config.message), dismissButton: .default(Text("OK")))
    }
    .confirmationDialog("Удалить всю историю?", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible) {
      Button("Удалить всё", role: .destructive) { vm.deleteAllSessions() }
      Button("Отмена", role: .cancel) { showDeleteAllConfirmation.toggle() }
    }
    .onAppear { vm.loadSessions() }
  }
}

// MARK: - Helper
private extension HistoryView {
  var filterSection: some View {
    VStack(spacing: 12) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          
        }
      }
    }
  }
}

// MARK: - Preview
#Preview {
  HistoryView()
}
