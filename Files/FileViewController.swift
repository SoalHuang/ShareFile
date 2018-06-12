//
//  FileViewController.swift
//  Files
//
//  Created by SoalHunag on 2018/6/11.
//  Copyright © 2018年 SoalHuang. All rights reserved.
//

import UIKit

private let OneKB: UInt64 = 1024
private let OneMB: UInt64 = 1024 * OneKB
private let OneGB: UInt64 = 1024 * OneMB
extension UInt64 {
    var fileSize: String {
        if self < OneKB {
            return "\(self) bytes"
        }
        if self < OneMB {
            return "\(self / OneKB) KB"
        }
        if self < OneGB {
            return "\(self / OneMB) MB"
        }
        return "\(self / OneGB) GB"
    }
}

final class FileViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let documents = NSHomeDirectory() + "/Documents"
    private var pathStack: [String] = []
    private var files: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Documents"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
        
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "FileCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50
        
        push(documents)
        reload()
    }
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: "re"), for: .normal)
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)
        return button
    }()
    
    @objc private func reload() {
        files = searchFiles()
        tableView.reloadData()
    }
}

extension FileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isRootPath ? files.count : files.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FileCell
        if isRootPath {
            cell.fileTitle.text = files[indexPath.row].0
            cell.fileSize.text = files[indexPath.row].1
            return cell
        }
        if indexPath.row == 0 {
            cell.fileTitle.text = ".."
            cell.icon.image = UIImage(named: "bk")
        } else {
            cell.fileTitle.text = files[indexPath.row - 1].0
            cell.fileSize.text = files[indexPath.row - 1].1
        }
        return cell
    }
}

extension FileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isRootPath, indexPath.row == 0 { return 40 }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isRootPath, indexPath.row == 0 {
            pop()
            reload()
            return
        }
        let file = files[isRootPath ? indexPath.row : indexPath.row - 1]
        let dict = try? FileManager.default.attributesOfItem(atPath: fullPath(file.0)) as NSDictionary
        guard let fileType = dict?.fileType(), fileType == FileAttributeType.typeDirectory.rawValue else {
            return
        }
        push(file.0)
        reload()
    }
}

extension FileViewController {
    private var isRootPath: Bool {
        return pathStack.count == 1
    }
    
    private func fullPath(_ lastComponents: String? = nil) -> String {
        guard let lc = lastComponents else { return pathStack.joined(separator: "/") }
        return pathStack.joined(separator: "/") + "/" + lc
    }
    
    private var current: String? {
        return pathStack.first
    }
    
    @discardableResult
    private func push(_ path: String) -> String? {
        pathStack.append(path)
        return pathStack.last
    }
    
    @discardableResult
    private func pop() -> String? {
        if isRootPath { return pathStack.last }
        pathStack.removeLast()
        return pathStack.last
    }
    
    private func searchFiles() -> [(String, String)] {
        let path = fullPath()
        let contents = try? FileManager.default.contentsOfDirectory(atPath: path)
        return contents?.compactMap({ (subPath) -> (String, String)? in
            guard let size = (try? FileManager.default.attributesOfItem(atPath: path + "/" + subPath) as NSDictionary)?.fileSize() else {
                return (subPath, "--")
            }
            return (subPath, size.fileSize)
        }) ?? []
    }
}
