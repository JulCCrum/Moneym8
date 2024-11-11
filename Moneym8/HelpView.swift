//
//  HelpView.swift
//  Moneym8

import SwiftUI

struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Help")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            
            List {
                Section(header: Text("GETTING STARTED")) {
                    FAQItem(question: "How do I add a transaction?",
                           answer: "Tap the + button in the Transactions tab. Choose between adding an expense or income, then fill in the details like amount, category, and optionally add a note.")
                    
                    FAQItem(question: "How do I edit or delete a transaction?",
                           answer: "Tap any transaction to view its details. There you can edit the transaction details or delete it entirely.")
                }
                
                Section(header: Text("CHARTS & ANALYTICS")) {
                    FAQItem(question: "What do the different charts show?",
                           answer: "• Bar Graph: Compare spending across categories\n• Line Graph: Track spending over time\n• Progress Circle: Shows budget usage\n• Sankey Diagram: Visualize money flow")
                    
                    FAQItem(question: "How do I change the time period?",
                           answer: "Use the time period selector (1D, 1W, 1M, 1Y) below any chart to adjust the data range being displayed.")
                }
                
                Section(header: Text("SUPPORT")) {
                    Button(action: {
                        if let url = URL(string: "mailto:support@moneym8.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Contact Support")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            },
            label: {
                Text(question)
                    .font(.body)
            }
        )
    }
}

#Preview {
    HelpView()
}
