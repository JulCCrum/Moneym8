import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let recurringVC = RecurringExpensesViewController()
        recurringVC.tabBarItem = UITabBarItem(title: "Recurring", image: UIImage(systemName: "arrow.2.circlepath"), tag: 1)
        
        let accountVC = AccountViewController()
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person"), tag: 2)
        
        viewControllers = [homeVC, recurringVC, accountVC].map { UINavigationController(rootViewController: $0) }
    }
}
