import SwiftUI
import CoreData

enum SortingType: String, CaseIterable {
    case new
    case old
    case completed
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isShowingAddNewGoalView = false
    @State private var sortingType: SortingType = .old

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.deadline, ascending: false)],
        animation: .default
    ) private var goals: FetchedResults<Goal>

    var sortedArray: [Goal] {
            switch sortingType {
            case .new:
                return goals.sorted { $0.deadline! > $1.deadline! }
            case .old:
                return goals.sorted { $0.deadline! < $1.deadline! }
            case .completed:
                let sortedGoals = goals.sorted { goal1, goal2 in
                    if goal1.isDone == goal2.isDone {
                        return goal1.deadline! < goal2.deadline!
                    } else {
                        return goal1.isDone && !goal2.isDone
                    }
                }
                return sortedGoals.filter { $0.isDone }
            }
        }
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "607274")
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 10) {
                    Picker("Sort By", selection: $sortingType) {
                        ForEach(SortingType.allCases, id: \.self) { sortType in
                            Text(sortType.rawValue.capitalized)
                                .tag(sortType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    List {
                        ForEach(sortedArray) { goal in
                            GoalListItemView(goal: goal)
                                .foregroundColor(.white)
                                .listRowBackground(Color(hex: "607274").opacity(0.8))
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteGoal(goal)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(Color(hex: "607274"))
                                    }
                                }
                        }
                    }
                    .background(Color.clear)
                    .navigationTitle("To Do List App")
                    .navigationBarTitleDisplayMode(.large)
                    .listStyle(PlainListStyle())
                    .padding(.bottom)

                    Button(action: {
                        isShowingAddNewGoalView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.white)
                            .font(.title)
                            .frame(width: 50, height: 50)
                            .background(Color(hex: "607274"))
                            .clipShape(Rectangle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "607274"), lineWidth: 2)
                            )
                    }
                }
                .padding()
            }
            .sheet(isPresented: $isShowingAddNewGoalView) {
                AddNewGoalView(isPresented: $isShowingAddNewGoalView)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        .environment(\.colorScheme, .dark)
    }

    private func deleteGoal(_ goal: Goal) {
        viewContext.delete(goal)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete goal: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, TheDB.shared.container.viewContext)
    }
}

struct GoalListItemView: View {
    @ObservedObject var goal: Goal

    var body: some View {
        HStack {
            Button {
                goal.isDone.toggle()
                do {
                    try goal.managedObjectContext?.save()
                } catch {
                    print("Failed to save changes: \(error.localizedDescription)")
                }
            } label: {
                Image(systemName: goal.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            VStack(alignment: .leading) {
                Text(goal.title ?? "Untitled")
                    .font(.title3)
                Text(goal.detail ?? "No details")
                    .font(.body)
                Text(goal.deadline?.formatted(date: .numeric, time: .shortened) ?? "No deadline")
                    .font(.callout)
            }
            .padding()
            .background(Color(hex: "607274"))
            .cornerRadius(8)
        }
        .padding()
    }
}

struct AddNewGoalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title = ""
    @State private var detail = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var deadline = Date()
    @Binding var isPresented: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor((Color(hex: "607274")))
                }
                .padding()
            }

            Group {
                TextField("Enter title", text: $title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                Divider()
                    .padding(.horizontal)
                TextField("Enter details", text: $detail)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                Divider()
                    .padding(.horizontal)
            }

            ZStack {
                Color(hex: "CCD3CA")
                    .opacity(0.8)
                    .cornerRadius(16)
                    .padding()

                DatePicker("Deadline", selection: $deadline, in: Date()...)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(Color(hex: "607274"))
                    .background(
                        Color(hex: "CCD3CA")
                            .opacity(0.2)
                            .blur(radius: 8)
                    )
                    .padding()
            }
            .padding()

            Button(action: {
                if title.isEmpty {
                    alertMessage = "Please enter a title."
                    showAlert = true
                } else if detail.isEmpty {
                    alertMessage = "Please enter details."
                    showAlert = true
                } else {
                    addNewGoal()
                }
            }) {
                Text("Add New Goal")
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "607274"))
                    .cornerRadius(8)
                    .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Warning"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .background(Color(hex: "CCD3CA"))
        .edgesIgnoringSafeArea(.bottom)
    }

    private func addNewGoal() {
        let newGoal = Goal(context: viewContext)
        newGoal.title = title
        newGoal.deadline = deadline
        newGoal.detail = detail
        newGoal.isDone = false

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save new goal: \(error.localizedDescription)")
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0

        scanner.scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
