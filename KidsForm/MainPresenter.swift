//
//  MainPresenter.swift
//  KidsForm
//
//  Created by Maksim Zimens on 18.02.2025.
//

import Foundation

// MARK: - Presenter Protocol

protocol MainPresenterProtocol: AnyObject {
    func numberOfCells() -> Int
    func personalDataForCell() -> CellDataModel
    func kidsDataForCell(_ index: Int) -> CellDataModel
    func didTapAddButton()
    func saveData(indexPath: IndexPath, text: String?, formType: FormType, cellType: MainHeaderViewStyle)
    func deleteItem(indexPath: IndexPath)
    func deleteAllItems()
}

// MARK: - Main Presenter

final class MainPresenter {
    
    // MARK: - Properties
    
    var kidsData: [CellDataModel] = []
    var personalData: CellDataModel = CellDataModel()
    
    weak var view: MainViewControllerProtocol?
    
    // MARK: - Methods
    
    private func addChild() {
        kidsData.append(CellDataModel())
    }
}

// MARK: - MainPresenterProtocol Implementation

extension MainPresenter: MainPresenterProtocol {
    
    // MARK: - Personal Data
    
    func personalDataForCell() -> CellDataModel {
        return personalData
    }
    
    func saveData(indexPath: IndexPath, text: String?, formType: FormType, cellType: MainHeaderViewStyle) {
        switch cellType {
        case .kidsInfo:
            switch formType {
            case .age:
                kidsData[indexPath.row].age = text
            case .name:
                kidsData[indexPath.row].name = text
            }
        case .personalInfo:
            switch formType {
            case .age:
                personalData.age = text
            case .name:
                personalData.name = text
            }
        }
    }
    
    // MARK: - Kids Data
    
    func kidsDataForCell(_ index: Int) -> CellDataModel {
        return kidsData[index]
    }
    
    func numberOfCells() -> Int {
        return kidsData.count
    }
    
    func deleteItem(indexPath: IndexPath) {
        kidsData.remove(at: indexPath.row)
        view?.reloadKidsSection()
    }
    
    func deleteAllItems() {
        personalData = CellDataModel()
        kidsData.removeAll()
        view?.reloadData()
    }
    
    // MARK: - Actions
    
    func didTapAddButton() {
        if kidsData.count < 5 {
            addChild()
            view?.reloadKidsSection()
        }
    }
}

