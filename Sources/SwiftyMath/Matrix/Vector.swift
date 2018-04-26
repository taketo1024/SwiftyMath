//
//  Vector.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2018/03/17.
//  Copyright © 2018年 Taketo Sano. All rights reserved.
//

import Foundation

public typealias ColVector<n: _Int, R: Ring> = Matrix<n, _1, R>
public typealias RowVector<m: _Int, R: Ring> = Matrix<_1, m, R>

public typealias Vector<n: _Int, R: Ring> = ColVector<n, R>
public typealias Vector2<R: Ring> = Vector<_2, R>
public typealias Vector3<R: Ring> = Vector<_3, R>
public typealias Vector4<R: Ring> = Vector<_4, R>

public extension ColVector where m == _1 {
    public subscript(index: Int) -> R {
        @_transparent
        get { return self[index, 0] }
        
        @_transparent
        set { self[index, 0] = newValue }
    }
}

public extension RowVector where n == _1 {
    public subscript(index: Int) -> R {
        @_transparent
        get { return self[0, index] }
        
        @_transparent
        set { self[0, index] = newValue }
    }
}

public typealias    DynamicVector<R: Ring> = DynamicColVector<R>
public typealias DynamicColVector<R: Ring> = ColVector<Dynamic, R>
public typealias DynamicRowVector<R: Ring> = RowVector<Dynamic, R>

public extension ColVector where n == Dynamic, m == _1 {
    public init(dim: Int, grid: [R]) {
        self.init(MatrixImpl(rows: dim, cols: 1, grid: grid))
    }
    
    public init(dim: Int, grid: R ...) {
        self.init(dim: dim, grid: grid)
    }
}

public extension RowVector where n == _1, m == Dynamic {
    public init(dim: Int, grid: [R]) {
        self.init(MatrixImpl(rows: 1, cols: dim, grid: grid))
    }
    
    public init(dim: Int, grid: R ...) {
        self.init(dim: dim, grid: grid)
    }
}
