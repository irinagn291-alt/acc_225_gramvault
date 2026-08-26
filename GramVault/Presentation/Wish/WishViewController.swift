// Role: VIPER view for the wish shelf.

import UIKit

@MainActor
final class WishViewController: UIViewController, WishViewProtocol, UITableViewDataSource, UITableViewDelegate {
    private let presenter: WishPresenterOutput
    private let table = UITableView(frame: .zero, style: .plain)
    private let empty = VaultEmptyPanel()
    private var rows: [WishRowModel] = []

    init(presenter: WishPresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "wish")
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.rowHeight = 64
        empty.action.addAction(UIAction { [weak self] _ in self?.presenter.handleEmpty() }, for: .touchUpInside)
        view.addSubview(table)
        view.addSubview(empty)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VaultMetrics.space(3)),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VaultMetrics.space(3))
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.handleAppear()
    }

    func render(_ model: WishScreenModel) {
        rows = model.rows
        empty.isHidden = model.empty == nil
        table.isHidden = model.empty != nil
        if let emptyModel = model.empty {
            empty.apply(image: emptyModel.image, title: emptyModel.title, copy: emptyModel.copy, actionTitle: emptyModel.action)
        }
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wish", for: indexPath)
        let row = rows[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.secondaryText = row.subtitle
        content.textProperties.font = VaultTypography.font(.headline)
        content.textProperties.color = VaultPalette.color(.ink)
        content.secondaryTextProperties.font = VaultTypography.font(.caption)
        content.secondaryTextProperties.color = VaultPalette.color(.muted)
        content.image = UIImage(named: "gvt_ProductPlaceholder")
        cell.contentConfiguration = content
        cell.backgroundColor = VaultPalette.color(.surface)
        cell.accessibilityLabel = row.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handlePromote(rows[indexPath.row].id)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, done in
            self?.presenter.handleRemove(self?.rows[indexPath.row].id ?? "")
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
}
