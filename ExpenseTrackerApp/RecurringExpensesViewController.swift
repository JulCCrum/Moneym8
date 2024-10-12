import UIKit

class RecurringExpensesViewController: UIViewController {
    
    private let calendarView = UICalendarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recurring Expenses"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure calendarView
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self
    }
}

extension RecurringExpensesViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // Return decorations for dates with recurring expenses
        return nil // Placeholder
    }
}
