//
//  LiveDeparturesBundle.swift
//  LiveDepartures
//
//  Created by William O'Connor on 17/09/2025.
//

import WidgetKit
import SwiftUI

@main
struct LiveDeparturesBundle: WidgetBundle {
    var body: some Widget {
        LiveDepartures()
        LiveDeparturesControl()
        LiveDeparturesLiveActivity()
    }
}
