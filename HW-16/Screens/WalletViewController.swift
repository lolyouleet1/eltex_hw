import UIKit

final class WalletViewController: UIViewController {
    // MARK: - UI
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Dependencies
    private let wallet: Wallet
    private let operationFormatter: OperationFormatter
    
    // MARK: - State
    private var balanceItems: [BotResultCellViewModel] = []
    
    // MARK: - Lifecycle
    init(wallet: Wallet, operationFormatter: OperationFormatter) {
        self.wallet = wallet
        self.operationFormatter = operationFormatter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationItem()
        setupTableView()
        setupHierarchy()
        setupConstraints()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
}

// MARK: - Setup
private extension WalletViewController {
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupNavigationItem() {
        navigationItem.title = Constants.screenTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.closeButtonImageName),
            style: .plain,
            target: self,
            action: #selector(handleCloseButtonTapped)
        )
        navigationController?.navigationBar.tintColor = Constants.primaryColor
    }
    
    func setupTableView() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.dataSource = self
        tableView.backgroundColor = Constants.tableBackgroundColor
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Constants.tableSeparatorColor
        tableView.separatorInset = .zero
        tableView.rowHeight = Constants.tableRowHeight
        tableView.estimatedRowHeight = Constants.tableRowHeight
        tableView.layer.cornerRadius = Constants.tableCornerRadius
        tableView.layer.borderWidth = Constants.tableBorderWidth
        tableView.layer.borderColor = Constants.tableBorderColor
        tableView.clipsToBounds = true
    }
    
    func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
    }
}

// MARK: - Constraints
private extension WalletViewController {
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.verticalInset),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.verticalInset),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -Constants.horizontalInset)
        ])
    }
}

// MARK: - Private Methods
private extension WalletViewController {
    func reloadData() {
        let snapshot = wallet.walletSnapshot()
        let sortedItems = snapshot.items.sorted {
            $0.currencyCode < $1.currencyCode
        }
        
        balanceItems = sortedItems.map {
            BotResultCellViewModel(
                text: operationFormatter.makeWalletBalanceText(for: $0),
                tone: .neutral
            )
        }
        
        emptyStateLabel.text = Constants.emptyStateText
        emptyStateLabel.textColor = Constants.primaryTextColor
        emptyStateLabel.font = .systemFont(ofSize: Constants.emptyStateFontSize, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = !balanceItems.isEmpty
        tableView.isHidden = balanceItems.isEmpty
        tableView.reloadData()
    }
}

// MARK: - Actions
private extension WalletViewController {
    @objc func handleCloseButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension WalletViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        balanceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier) as? TableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        cell.currentResult = balanceItems[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - Constants
private extension WalletViewController {
    enum Constants {
        static let screenTitle = "Wallet"
        static let emptyStateText = "Wallet is empty"
        static let closeButtonImageName = "xmark.circle"
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let tableBackgroundColor: UIColor = .white
        static let tableSeparatorColor = UIColor(red: 0.90, green: 0.89, blue: 0.96, alpha: 1)
        static let tableBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let horizontalInset: CGFloat = 24
        static let verticalInset: CGFloat = 16
        static let tableCornerRadius: CGFloat = 6
        static let tableBorderWidth: CGFloat = 1
        static let tableRowHeight: CGFloat = 56
        static let emptyStateFontSize: CGFloat = 17
    }
}
