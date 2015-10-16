//
//  CCTiledMap+Utility.swift
//  AdventureGame
//
//  Created by asu on 2015-10-15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class SnakeTileMap {
    
    var tileSize: CGSize = CGSize(width: 37,height: 37)
    
    func tileIndexesAt(point point:CGPoint) -> (row:Int, column:Int){
		let row = Int(point.x) / Int(tileSize.width)
        let column = Int(point.y) / Int(tileSize.height)
        return (row, column)
    }

    func tileAt(point point:CGPoint) -> CGRect {
        let (row, column) = tileIndexesAt(point: point)
        return CGRectMake(CGFloat(row) * tileSize.width, CGFloat(column) * tileSize.height, tileSize.width, tileSize.height)
    }
    
    func tileAt(sprite sprite:CCSprite) -> CGRect{
        return tileAt(point: sprite.position)
    }
    
    func direction(from from:CGPoint, to:CGPoint) -> MoveDirection{
		let toTile = tileAt(point: to)
        let fromTile = tileAt(point: from)
        
        if (sameTile(pointA:from, pointB:to)){
        	return .None
        } else if (fromTile.origin.x == toTile.origin.x){
            return (fromTile.origin.y < toTile.origin.y) ? .Down : .Up
        } else {
            return (fromTile.origin.x < toTile.origin.x) ? .Right : .Left
        }
    }
    
    func sameTile(pointA pointA:CGPoint, pointB:CGPoint) -> Bool{
        let aTile = tileAt(point: pointA)
        let bTile = tileAt(point: pointB)
        
        return (aTile.origin.x == bTile.origin.x && aTile.origin.y == bTile.origin.y)
    }
    
    
    func nextTile(forSprite sprite:CCSprite, inDirection direction: MoveDirection) -> CGRect?{
        
        var next = tileAt(sprite:sprite)
        
        switch(direction){
        case .Up:
            next.origin.y -= tileSize.height
        case .Down:
            next.origin.y += tileSize.height
        case .Left:
            next.origin.x -= tileSize.width
        case .Right:
            next.origin.x += tileSize.width
        default:
            return nil
        }
 
        
        return next
    }

    
}
