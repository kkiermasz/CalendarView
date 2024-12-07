//
//  MCalendarView.swift of CalendarView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public struct MCalendarView: View {
    @StateObject var selectedData: Data.MCalendarView
    @State var scrolledID: Date? = {
      Date.now.start(of: .month)
    }()
    let monthsData: [Data.MonthView]
    let configData: CalendarConfig

    init(_ selectedDate: Binding<Date?>?, _ selectedRange: Binding<MDateRange?>?, _ configBuilder: (CalendarConfig) -> CalendarConfig) {
        self._selectedData = .init(wrappedValue: .init(selectedDate, selectedRange))
        self.configData = configBuilder(.init())
        self.monthsData = .generate()
    }
    public var body: some View {
        VStack(spacing: 12) {
            createWeekdaysView()
            createScrollView()
        }
    }
}
private extension MCalendarView {
    func createWeekdaysView() -> some View {
        configData.weekdaysView().erased()
    }
  func createScrollView() -> some View {
    ScrollViewReader { proxy in
      ScrollView(showsIndicators: false) {
        LazyVStack(spacing: configData.monthsSpacing) {
          ForEach(monthsData, id: \.month, content: createMonthItem)
        }
        .padding(.top, configData.monthsPadding.top)
        .padding(.bottom, configData.monthsPadding.bottom)
        .background(configData.monthsViewBackground)
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.viewAligned)
      .onChange(of: selectedData.date) {
        guard let date = selectedData.date else { return }
        withAnimation {
          proxy.scrollTo(date.start(of: .month), anchor: .top)
        }
      }
      .task {
        proxy.scrollTo(scrolledID, anchor: .top)
      }
    }
  }
}
private extension MCalendarView {
    func createMonthItem(_ data: Data.MonthView) -> some View {
        VStack(spacing: configData.monthLabelDaysSpacing) {
            createMonthLabel(data.month)
            createMonthView(data)
        }
        .id(data.month)
    }
}
private extension MCalendarView {
    func createMonthLabel(_ month: Date) -> some View {
        configData.monthLabel(month)
            .erased()
            .onAppear { onMonthChange(month) }
    }
    func createMonthView(_ data: Data.MonthView) -> some View {
        MonthView(selectedDate: $selectedData.date, selectedRange: $selectedData.range, data: data, config: configData)
    }
}

// MARK: - Modifiers
private extension MCalendarView {
    func onMonthChange(_ date: Date) { configData.onMonthChange(date) }
}
