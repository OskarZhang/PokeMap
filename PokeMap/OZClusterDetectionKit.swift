//
//  OZClusterDetection.swift
//  PokeMap
//
//  Created by Oskar Zhang on 7/30/16.
//  Copyright © 2016 OskarZhang. All rights reserved.
//

import Foundation
class OZClusterDetection {
    
    func clusterItems(items:[OZClusterItem],gridCellSize:CGFloat,latitudeRange:(Double,Double),longituteRange:(Double,Double)) -> [OZCluster] {
        let numCell = Int(UIScreen.mainScreen().bounds.width / gridCellSize) * Int(UIScreen.mainScreen().bounds.height / gridCellSize)
        var retVal = Array<OZCluster>()
        for i in 0...numCell {
////            let minLatitide =
//            let cluster = OZCluster(items: [], latitudeRange: <#T##(Double, Double)#>, longitutdeRange: <#T##(Double, Double)#>)
        }
        
        return []
    }
}


struct OZCluster {
    var items:[OZClusterItem]
    var count:Int {
        get {
            return items.count
        }
    }
    var latitudeRange:(Double,Double)
    var longitutdeRange:(Double,Double)
}

protocol OZClusterItem {
    var latitude:Double{get set}
    var longitutde:Double{get set}
}