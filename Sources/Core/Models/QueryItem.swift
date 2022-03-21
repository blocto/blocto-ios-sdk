//
//  QueryItem.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/16.
//

import Foundation

struct QueryItem {

    let name: QueryName
    let value: Any

    init(name: QueryName, value: Any) {
        self.name = name
        self.value = value
    }

}
