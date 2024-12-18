//
//  CalendarView.swift
//  daiii2
//
//  Created by Silvia Lembo on 18/12/24.
//import SwiftUI

import SwiftUI

struct CalendarView: View {
    @State private var currentDate: Date = Date()
    @State private var emojiDays: [Date: String] = [:]
    @State private var showAlert: Bool = false
    @State private var selectedDate: Date? = nil

    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let monthDays = range.compactMap { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: currentDate)
        }
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysToAdd = (firstWeekday - 1)
        
        var allDays = [Date]()
        for i in 0..<daysToAdd {
            if let previousDay = calendar.date(byAdding: .day, value: -i - 1, to: firstDayOfMonth) {
                allDays.insert(previousDay, at: 0)
            }
        }
        
        allDays.append(contentsOf: monthDays)
        
        let lastDayOfMonth = monthDays.last!
        let lastWeekday = calendar.component(.weekday, from: lastDayOfMonth)
        let daysToAddNext = 7 - lastWeekday
        
        for day in 1...daysToAddNext {
            if let nextDay = calendar.date(byAdding: .day, value: day, to: lastDayOfMonth) {
                allDays.append(nextDay)
            }
        }
        
        return allDays
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(.green1)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack {
                    HStack {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .clipShape(Circle())
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Text(currentDate, formatter: DateFormatter.monthYear)
                            .font(.title.bold())
                            .foregroundColor(.green)
                        Spacer()
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .clipShape(Circle())
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(20)
                .shadow(radius: 5)

                // Calendar grid
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(daysInMonth, id: \.self) { date in
                        let day = Calendar.current.component(.day, from: date)
                        let isCurrentMonth = Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .month)
                        
                        Button(action: {
                            selectedDate = date
                            showAlert = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(isCurrentMonth ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 45, height: 45)
                                Text(emojiDays[date] ?? "\(day)")
                                    .font(.headline)
                                    .foregroundColor(isCurrentMonth ? .green : .gray)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.top, 30) // Sposta il calendario più in alto
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(20)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Hai annaffiato le tue piante?"),
                    message: Text("Seleziona Sì se hai annaffiato le piante oggi."),
                    primaryButton: .default(Text("Sì")) {
                        if let date = selectedDate {
                            emojiDays[date] = "💧"
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}

extension DateFormatter {
    static var monthYear: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "MMMM yyyy"
        return format
    }
}
