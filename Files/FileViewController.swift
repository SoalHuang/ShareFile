//
//  FileViewController.swift
//  Files
//
//  Created by SoalHunag on 2018/6/11.
//  Copyright © 2018年 SoalHuang. All rights reserved.
//

import UIKit

private let OneKB: UInt64 = 1024
private let OneMB: UInt64 = 1024 * 1024
extension UInt64 {
    var fileSize: String {
        if self < OneKB {
            return "\(self) Byte"
        }
        if self < OneMB {
            return "\(self / OneKB) KB"
        }
        return "\(self / OneMB) MB"
    }
}

final class FileViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var files: [(String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Documents"
        
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "FileCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50
        
        files = searchFiles()
        tableView.reloadData()
    }
    
    private func searchFiles() -> [(String, String)] {
        let documents = NSHomeDirectory() + "/Documents"
        let subs = FileManager.default.subpaths(atPath: documents)
        return subs?.compactMap({ (path) -> (String, String)? in
            guard let size = (try? FileManager.default.attributesOfItem(atPath: documents + "/" + path) as NSDictionary)?.fileSize() else {
                return (path, "unknow")
            }
            return (path, size.fileSize)
        }) ?? []
    }
}

extension FileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FileCell
        cell.fileTitle.text = files[indexPath.row].0
        cell.fileSize.text = files[indexPath.row].1
        return cell
    }
}
