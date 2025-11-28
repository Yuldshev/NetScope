import SwiftUI

struct HistoryView: View {
  @StateObject private var vm = HistoryViewModel()
  @State private var selectedSession: ScanSessionModel?
  @State private var showDeleteAllConfirmation = false
  @State private var showDateFilter = false
  
  var body: some View {
    ZStack {
      mainContent
    }
    .navigationTitle("История сканирования")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar { toolbarContent }
    .sheet(isPresented: $showDateFilter) { DateFilterView(viewModel: vm) }
    .alert(item: $vm.alertConfig) { config in
      Alert(title: Text(config.title), message: Text(config.message), dismissButton: .default(Text("OK")))
    }
    .confirmationDialog("Удалить всю историю?", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible) {
      Button("Удалить всё", role: .destructive) { vm.deleteAllSessions() }
      Button("Отмена", role: .cancel) { showDeleteAllConfirmation.toggle() }
    }
    .overlay { errorOverlay }
    .onAppear { vm.loadSessions() }
    .refreshable { vm.loadSessions(forceReload: true) }
  }
}

// MARK: - Helper
private extension HistoryView {
  @ViewBuilder
  var mainContent: some View {
    VStack(spacing: 0) {
      if vm.hasSessions {
        FilterSectionView(vm: vm)
          .padding(.horizontal)
      }

      if vm.filteredSessions.isEmpty {
        if vm.hasSessions {
          EmptyStateView(
            icon: "line.3.horizontal.decrease.circle",
            title: "Нет результатов",
            subtitle: "Попробуйте изменить фильтр",
            actionTitle: "Сбросить фильтр"
          ) { vm.clearFilter() }
        } else {
          EmptyStateView(
            icon: "clock.arrow.circlepath",
            title: "История пуста",
            subtitle: "Выполните сканирование для создания истории"
          ).padding()
        }
      } else {
        sessionsList
      }
    }
  }
  
  var sessionsList: some View {
    List {
      ForEach(vm.filteredSessions) { session in
        NavigationLink(destination: SessionDetailView(session: session)) {
          SessionRowView(session: session)
        }
      }
      .onDelete { offsets in
        vm.deleteSessions(at: offsets)
      }
    }
    .listStyle(.insetGrouped)
  }
  
  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Menu {
        Button { showDateFilter.toggle() } label: {
          CustomLabel(title: "Фильтр по дате", icon: "calendar")
        }
        
        if vm.isFilteringActive {
          Button { vm.clearFilter() } label: {
            CustomLabel(title: "Сбросить фильтр", icon: "xmark.circle")
          }
        }
        
        Divider()
        
        Button { showDeleteAllConfirmation.toggle() } label: {
          CustomLabel(title: "Удалить всё", icon: "trash")
        }
      } label: {
        Image(systemName: "ellipsis.circle")
      }
    }
  }
  
  @ViewBuilder
  var errorOverlay: some View {
    if case .error(let message) = vm.loadingState {
      VStack(spacing: 16) {
        Image(systemName: "exclamationmark.triangle")
          .font(.system(size: 50))
          .foregroundColor(.red)

        Text("Ошибка загрузки")
          .font(.headline)

        Text(message)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)

        Button("Повторить") {
          vm.loadSessions()
        }
        .buttonStyle(.borderedProminent)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemBackground))
    }
  }
}

// MARK: - Preview
#Preview {
  HistoryView()
}
