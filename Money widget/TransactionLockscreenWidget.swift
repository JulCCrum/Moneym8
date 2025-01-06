//
//  TransactionLockScreenWidget.swift
//  Money widget
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            Link(destination: URL(string: "moneym8://addexpense")!) {
                ZStack {
                    if #available(iOS 16.0, *) {
                        AccessoryWidgetBackground()
                    }
                    VStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Add")
                            .font(.system(size: 10))
                    }
                }
            }

        default:
            // For any other widget family (like .systemMedium),
            // show nothing, since we only support .accessoryCircular.
            EmptyView()
        }
    }
}

@main
struct TransactionLockScreenWidget: Widget {
    let kind: String = "TransactionLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView()
        }
        .configurationDisplayName("Quick Add")
        .description("Quickly add transactions from your lock screen.")
        // IMPORTANT: Only accessoryCircular is supported here.
        .supportedFamilies([.accessoryCircular])
    }
}
