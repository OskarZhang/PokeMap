//
//  AppCoordinator.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/16/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
import UIKit
typealias AppCoordinatorStepBlock = ()->()
protocol AppCoordinator {
    weak var mainVC:MainMapViewController! { get set }
    weak var activeVC:UIViewController! { get set }
    
}