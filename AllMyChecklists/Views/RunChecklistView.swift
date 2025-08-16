import SwiftUI
import SwiftData

struct RunChecklistView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var haptics: HapticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var run: ChecklistRun
    @State private var animateProgress = false

    init(existingRun: ChecklistRun) {
        _run = State(initialValue: existingRun)
    }

    private var progress: Double {
        guard !run.items.isEmpty else { return 0 }
        let done = run.items.filter { $0.isChecked }.count
        return Double(done) / Double(run.items.count)
    }

    var body: some View {
        ZStack {
            // Stunning gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.95, blue: 0.97),
                    Color(red: 0.93, green: 0.96, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Beautiful progress section
                    VStack(spacing: 16) {
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color.black.opacity(0.05), lineWidth: 12)
                                .frame(width: 120, height: 120)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: animateProgress ? progress : 0)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.8, blue: 0.5),
                                            Color(red: 0.2, green: 0.6, blue: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                            
                            // Percentage text
                            VStack(spacing: 4) {
                                Text("\(Int(progress * 100))")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(red: 0.2, green: 0.2, blue: 0.3), Color(red: 0.3, green: 0.3, blue: 0.4)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("%")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        .onAppear {
                            animateProgress = true
                        }
                        
                        Text(progress == 1.0 ? "Complete! 🎉" : "Keep going!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.3))
                    }
                    .padding(.top, 20)
                    
                    // Beautiful checklist items
                    VStack(spacing: 12) {
                        ForEach(run.items.sorted(by: { $0.sortOrder < $1.sortOrder })) { item in
                            Button(action: { toggle(item) }) {
                                HStack(spacing: 16) {
                                    // Stunning checkbox
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(item.isChecked ? 
                                                LinearGradient(
                                                    colors: [Color(red: 0.3, green: 0.8, blue: 0.5), Color(red: 0.2, green: 0.7, blue: 0.4)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) : LinearGradient(
                                                    colors: [Color.white],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(item.isChecked ? Color.clear : Color(white: 0.85), lineWidth: 2)
                                            )
                                            .shadow(color: item.isChecked ? Color.green.opacity(0.3) : .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        
                                        if item.isChecked {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    // Content
                                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(item.isChecked ? Color(white: 0.6) : Color(white: 0.1))
                                            .strikethrough(item.isChecked, color: Color(white: 0.7))
                                        
                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(white: 0.6))
                                                .lineLimit(2)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Finish button
                    if canFinish {
                        Button(action: finish) {
                            ZStack {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.8, blue: 0.5),
                                                Color(red: 0.2, green: 0.6, blue: 0.9)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 56)
                                    .shadow(color: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.5), radius: 16, x: 0, y: 8)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Complete Checklist")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle(run.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canFinish: Bool {
        // If there are required items, ensure they are checked
        let required = run.items.filter { _ in true } // future: carry required flag per item if needed
        if required.isEmpty { return true }
        return required.allSatisfy { $0.isChecked }
    }

    private func toggle(_ item: ChecklistRunItem) {
        if let idx = run.items.firstIndex(where: { $0.id == item.id }) {
            run.items[idx].isChecked.toggle()
            try? context.save()
            haptics.light()
        }
    }

    private func finish() {
        run.completedAt = .now
        try? context.save()
        haptics.success()
        dismiss()
    }
}

