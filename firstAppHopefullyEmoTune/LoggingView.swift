//
//  LoggingView.swift
//  firstAppHopefullyEmoTune
//
//  Created by Admin on 1/15/25.
//

import SwiftUI

@propertyWrapper
struct Storage<T: AppStorageConvertible>: RawRepresentable {
    var rawValue: String { wrappedValue.storedValue }
    var wrappedValue: T

    init?(rawValue: String) {
        guard let value = T.init(rawValue) else { return nil }
        self.wrappedValue = value
    }
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension Binding {
    func binding<T>() -> Binding<T> where Value == Storage<T> {
        return .init(
            get: { wrappedValue.wrappedValue },
            set: { value, transaction in
                self.transaction(transaction).wrappedValue.wrappedValue = value
            }
        )
    }
}

protocol AppStorageConvertible {
    init?(_ storedValue: String)
    var storedValue: String { get }
}

extension RawRepresentable where RawValue: LosslessStringConvertible, Self: AppStorageConvertible {
    init?(_ storedValue: String) {
        guard let value = RawValue(storedValue) else { return nil }
        self.init(rawValue: value)
    }
    var storedValue: String {
        String(describing: rawValue)
    }
}

extension Array: AppStorageConvertible where Element: LosslessStringConvertible {
    public init?(_ storedValue: String) {
        let values = storedValue.components(separatedBy: ",")
        self = values.compactMap(Element.init)
    }
    var storedValue: String {
        return map(\.description).joined(separator: ",")
    }
}

struct Day: Identifiable {
    let date: String
    let goalHit: Bool
    var id: String { date }
}

struct LoggingView: View {
    
    let formatter = DateFormatter()
    
    @Binding var timeToHitGoal: Int
    @Binding var goalHit: Bool
    @Binding var shouldShowLogging: Bool
    @Binding var totalMins: Double
    @Binding var daysGoalHitCount: Int
    @Binding @Storage var datesGoalHit: [String]
    @Binding var datesGoalHitStruct: [Day]
    @Binding var daysLoggedIn: Int
    //  >^. x .^<
    
    var body: some View {
        
        VStack {
                
            if datesGoalHit.count > 0 {
                //will be updated so that it's > 0 and no test showing
                
                ScrollView(.vertical) {
                    
                    ForEach(datesGoalHitStruct) { dates in
                        VStack {
                            HStack {
                                Text(dates.date)
                                    .padding(.horizontal, 30)
                                Spacer()
                                if dates.goalHit {
                                    Text("Goal hit!")
                                        .padding()
                                } else {
                                    Text("Goal missed.")
                                        .padding(.horizontal, 30)
                                }
                            }
                            .padding(.vertical, 10)
                            
                            Text("_______________________________________")
                        }
                    }
                    
                    HStack {
                        Text("Total minutes practiced:")
                        Text("\(Int(totalMins))" + " mins")
                    }
                    .padding(.horizontal, 50)
                    .padding()
                    
                    HStack {
                        Text("Days logged in:")
                        Text("\(daysLoggedIn)" + " days")
                    }
                    
                    .padding(.horizontal, 50)
                    .padding()
                    
                    HStack {
                        Text("Total days with goal hit:")
                        Text("\(daysGoalHitCount)" + " days")
                    }
                    .padding(.horizontal, 50)
                    .padding()
                    
                }
                .defaultScrollAnchor(.bottom)
            } else {
                
                Text("You haven't met your practice goal for any days yet.")
                    .padding(.horizontal, 50)
                    .padding()
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text("Total minutes practiced:")
                    Text("\(Int(totalMins))" + " mins")
                }
                .padding(.horizontal, 50)
                .padding()
                
                HStack {
                    Text("Days logged in:")
                    Text("\(daysLoggedIn)" + " days")
                }
                
                .padding(.horizontal, 50)
                .padding()
                
            }
            
            Button {
                shouldShowLogging.toggle()
            } label: {
                Text("Exit")
            }
            .padding()
            
        }
        
    }
}

#Preview {
    LoggingView(timeToHitGoal: .constant(10), goalHit: .constant(true), shouldShowLogging: .constant(true), totalMins: .constant(7.11), daysGoalHitCount: .constant(12), datesGoalHit: .constant(Storage(wrappedValue: [""])), datesGoalHitStruct: .constant([Day(date: "testing", goalHit: true)]), daysLoggedIn: .constant(15))
}
