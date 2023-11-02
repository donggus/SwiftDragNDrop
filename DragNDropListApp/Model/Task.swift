//
//  Task.swift
//  DragNDropListApp
//
//  Created by Gustavo Dong on 02/11/2023.
//

import SwiftUI

struct Task: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var status: Status
}

enum Status {
    case todo
    case working
    case completed
}
