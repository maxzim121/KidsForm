//
//  ViewController.swift
//  KidsForm
//
//  Created by Maksim Zimens on 17.02.2025.
//

import UIKit

// MARK: - Constants
private enum CollectionViewIdentifiers {
    static let mainCell = "MainCollectionViewCell"
    static let headerView = "MainCollectionHeaderView"
    static let footerView = "MainCollectionFooterView"
}

// MARK: - Protocols
protocol CellToViewControllerProtocol: AnyObject {
    func editingEnded(indexPath: IndexPath, text: String?, formType: FormType, cellType: MainHeaderViewStyle)
    func didTapDeleteButton(indexPath: IndexPath)
}

protocol MainViewControllerProtocol: AnyObject {
    func reloadKidsSection()
    func reloadData()
}

// MARK: - MainViewController
final class MainViewController: UIViewController {
    
    // MARK: - Properties
    private var presenter: MainPresenterProtocol
    
    private lazy var mainCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isUserInteractionEnabled = true
        collection.isScrollEnabled = true
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewIdentifiers.mainCell)
        collection.register(MainHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewIdentifiers.headerView)
        collection.register(MainFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewIdentifiers.footerView)
        return collection
    }()
    
    // MARK: - Initializer
    init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mainCollection.delegate = self
        mainCollection.dataSource = self
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupConstraints() {
        view.addSubview(mainCollection)
        mainCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : presenter.numberOfCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewIdentifiers.mainCell, for: indexPath) as? MainCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let cellsCount = presenter.numberOfCells()
        if indexPath.section == 0 {
            cell.setupCell(cellType: .personalInfo, cellData: presenter.personalDataForCell(), indexPath: indexPath, cellsCount: cellsCount)
        } else {
            cell.setupCell(cellType: .kidsInfo, cellData: presenter.kidsDataForCell(indexPath.row), indexPath: indexPath, cellsCount: cellsCount)
        }
        
        cell.viewController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return setupHeaderView(at: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return setupFooterView(at: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
    
    // MARK: - Header and Footer Setup
    private func setupHeaderView(at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = mainCollection.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewIdentifiers.headerView, for: indexPath) as? MainHeaderView else {
            return UICollectionReusableView()
        }
        let style: MainHeaderViewStyle = indexPath.section == 0 ? .personalInfo : .kidsInfo
        headerView.setup(headerStyle: style, cellsCount: presenter.numberOfCells())
        headerView.viewController = self
        return headerView
    }

    private func setupFooterView(at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footerView = mainCollection.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewIdentifiers.footerView, for: indexPath) as? MainFooterView else {
            return UICollectionReusableView()
        }
        if indexPath.section == 1 {
            footerView.delegate = self
        }
        return footerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == 1 && presenter.numberOfCells() > 0 ? CGSize(width: collectionView.frame.width, height: 60) : .zero
    }
}

// MARK: - MainViewControllerProtocol
extension MainViewController: MainViewControllerProtocol {
    func reloadKidsSection() {
        mainCollection.reloadSections([1])
    }
    
    func reloadData() {
        mainCollection.reloadData()
    }
}

// MARK: - HeaderDelegate
extension MainViewController: HeaderDelegate {
    func didTapAddButton() {
        presenter.didTapAddButton()
    }
}

// MARK: - CellToViewControllerProtocol
extension MainViewController: CellToViewControllerProtocol {
    func editingEnded(indexPath: IndexPath, text: String?, formType: FormType, cellType: MainHeaderViewStyle) {
        presenter.saveData(indexPath: indexPath, text: text, formType: formType, cellType: cellType)
    }
    
    func didTapDeleteButton(indexPath: IndexPath) {
        presenter.deleteItem(indexPath: indexPath)
    }
}

// MARK: - FooterDelegate
extension MainViewController: FooterDelegate {
    func didTapDeleteAllButton() {
        let alert = UIAlertController(title: "Очистить данные?", message: "Все введённые данные будут удалены", preferredStyle: .actionSheet)
        
        let resetAction = UIAlertAction(title: "Сбросить данные", style: .destructive) { _ in
            self.presenter.deleteAllItems()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
