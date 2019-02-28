//
//  SearchPushRow.swift
//  HCFA
//

import Eureka

extension String: SearchItem {
    public func matchesSearchQuery(_ query: String) -> Bool {
        let lower = self.lowercased()
        for q in query.lowercased().split(separator: " ") {
            if !lower.contains(q) {
                return false
            }
        }
        return true
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

//  Obtained from https://gist.github.com/gotelgest/cf309f6e2095ff22a20b09ba5c95be36
open class _SearchSelectorViewController<Row: SelectableRowType, OptionsRow: OptionsProviderRow>: SelectorViewController<OptionsRow>, UISearchResultsUpdating where Row.Cell.Value: SearchItem {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var originalOptions = [[ListCheckRow<Row.Cell.Value>]]()
    var currentOptions = [[ListCheckRow<Row.Cell.Value>]]()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        textFieldInsideSearchBar?.font = formHeaderFont
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = .white
        
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = .white
        
        if let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(UIImage(named: "clear"), for: .normal)
            clearButton.tintColor = .white
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    public func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        if query.isEmpty {
            currentOptions = originalOptions
        } else {
            currentOptions = []
            for section in originalOptions {
                currentOptions.append(section.filter { $0.selectableValue?.matchesSearchQuery(query) ?? false })
            }
        }
        tableView.reloadData()
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return currentOptions[section].count == 0 ? 0 : super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return currentOptions[section].count == 0 ? 0 : super.tableView(tableView, heightForFooterInSection: section)
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return currentOptions.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOptions[section].count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = currentOptions[indexPath.section][indexPath.row]
        option.updateCell()
        return option.baseCell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentOptions[indexPath.section][indexPath.row].didSelect()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open override func setupForm(with options: [OptionsRow.OptionsProviderType.Option]) {
        super.setupForm(with: options)
        originalOptions = []
        for section in form.allSections {
            if let allRows = section.map({ $0 }) as? [ListCheckRow<Row.Cell.Value>] {
                originalOptions.append(allRows)
            }
        }
        currentOptions = originalOptions
        tableView.reloadData()
    }
}

open class SearchSelectorViewController<OptionsRow: OptionsProviderRow>: _SearchSelectorViewController<ListCheckRow<OptionsRow.OptionsProviderType.Option>, OptionsRow> where OptionsRow.OptionsProviderType.Option: SearchItem {
}

open class _SearchPushRow<Cell: CellType> : SelectorRow<Cell> where Cell: BaseCell, Cell.Value : SearchItem {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return SearchSelectorViewController<SelectorRow<Cell>> { _ in } }, onDismiss: { vc in
            let _ = vc.navigationController?.popViewController(animated: true) })
    }
}

public final class SearchPushRow<T: Equatable> : _SearchPushRow<PushSelectorCell<T>>, RowType where T: SearchItem {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public protocol SearchItem {
    func matchesSearchQuery(_ query: String) -> Bool
}
