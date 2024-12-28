import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 2) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Add")
                        .font(.system(size: 10))
                }
            }
            .widgetURL(URL(string: "moneym8://addexpense"))
            
        default:
            EmptyView()
        }
    }
}

struct TransactionLockScreenWidget: Widget {
    private let supportedFamilies: [WidgetFamily] = [.accessoryCircular]
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.moneym8.addexpense", provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Add")
        .description("Quickly add transactions from your lock screen")
        .supportedFamilies(supportedFamilies)
    }
}
