//
//  QueryItem.swift
//  BloctoSDK
//
//  Created by Andrew Wang on 2022/3/16.
//

import Foundation

public struct QueryItem {

    let name: String
    let value: Any

    init(name: QueryName, value: Any) {
        self.name = name.rawValue
        self.value = value
    }

    init(nameString: String, value: Any) {
        self.name = nameString
        self.value = value
    }

    var getQueryComponents: [URLQueryItem] {
        URLEncoding.queryComponents(fromKey: name, value: value)
    }

}
