import UIKit
import Foundation

final class GraphViewController: UIViewController {
    // MARK: - UI
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // MARK: - Dependencies
    private let session: TradingSession
    
    // MARK: - Lifecycle
    init(tradingSession: TradingSession) {
        self.session = tradingSession
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        collectionView.backgroundColor = .gray
        
        setupHierarchy()
        setupConstraints()
        setupCollectionView()
    }
}

// MARK: - Setup
private extension GraphViewController {
    func setupHierarchy() {
        view.addSubview(collectionView)
    }
    
    func setupCollectionView() {
        collectionView.register(GraphCell.self, forCellWithReuseIdentifier: GraphCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - Constraints
private extension GraphViewController {
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.collectionViewVerticalInset),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.collectionViewVerticalInset),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension GraphViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return session.operations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GraphCell.identifier,
            for: indexPath
        ) as? GraphCell else {
            fatalError("Could not dequeue GraphCell")
        }
        
        cell.configure(with: session.candlesticks[indexPath.item])
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GraphViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        return
    }
}

// MARK: - Constants
private extension GraphViewController {
    enum Constants {
        static let collectionViewVerticalInset: CGFloat = 180
    }
}
