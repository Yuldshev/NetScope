import SwiftUI

struct FilterSectionView: View {
  let vm: HistoryViewModel
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(FilterType.allCases, id: \.self) { type in
          FilterChip(title: type.title, isActive: type.isActive(in: vm)) {
            type.apply(on: vm)
          }
        }
        
        if vm.isFilteringActive {
          FilterChip(title: "Сбросить", isActive: false) { vm.clearFilter() }
        }
      }
      .padding(.bottom, 8)
    }
  }
}

// MARK: - FilterType
private enum FilterType: CaseIterable {
  case today, week, month
  
  var title: String {
    switch self {
    case .today: return "Сегодня"
    case .week: return "Неделя"
    case .month: return "Месяц"
    }
  }
  
  func isActive(in vm: HistoryViewModel) -> Bool {
    switch self {
    case .today: return vm.isTodayFilterActive
    case .week: return vm.isWeekFilterActive
    case .month: return vm.isMonthFilterActive
    }
  }
  
  func apply(on vm: HistoryViewModel) {
    switch self {
    case .today: vm.filterToday()
    case .week: vm.filterLastWeek()
    case .month: vm.filterLastMonth()
    }
  }
}

// MARK: - Preview
#Preview {
  FilterSectionView(vm: HistoryViewModel())
}
