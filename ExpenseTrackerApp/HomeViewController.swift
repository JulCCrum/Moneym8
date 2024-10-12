import UIKit
import Charts

class HomeViewController: UIViewController {
    
    private let chartView = LineChartView()
    private let expensesTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        setupUI()
    }
    
    private func setupUI() {
        // Add and configure chartView
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chartView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Add and configure expensesTableView
        view.addSubview(expensesTableView)
        expensesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expensesTableView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
            expensesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expensesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            expensesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure expensesTableView
        expensesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
        expensesTableView.dataSource = self
        expensesTableView.delegate = self
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of expenses
        return 0 // Placeholder
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        // Configure the cell with expense data
        return cell
    }
}
