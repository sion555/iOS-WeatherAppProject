//
//  Protocols.swift
//  iosProject-5
//
//  Created by 한범석 on 4/15/24.
//

import Foundation


protocol LocationSelectionDelegate: AnyObject {
    func locationSelected(_ location: (latitude: Double, longitude: Double))
}
