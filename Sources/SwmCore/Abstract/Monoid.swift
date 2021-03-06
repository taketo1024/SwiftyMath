public protocol Multiplicative {
    static func * (a: Self, b: Self) -> Self
}

public protocol Monoid: MathSet, Multiplicative {
    static var identity: Self { get }
    var isIdentity: Bool { get }
    var inverse: Self? { get }
    var isInvertible: Bool { get }
    func pow(_ n: Int) -> Self
    static func multiply<S: Sequence>(_ elements: S) -> Self where S.Element == Self
}

public extension Monoid {
    @inlinable
    var isIdentity: Bool {
        return self == .identity
    }
    
    @inlinable
    var isInvertible: Bool {
        inverse != nil
    }
    
    func pow(_ n: Int) -> Self {
        switch n {
        case 0:
            return .identity
        case 1:
            return self
        case _ where n > 0:
            return (0 ..< n - 1).reduce(self){ (res, _) in
                res * self
            }
        case _ where n < 0:
            guard let inv = inverse else {
                fatalError()
            }
            return (0 ..< -n - 1).reduce(inv){ (res, _) in
                res * inv
            }
        default:
            fatalError()
        }
    }
    
    @inlinable
    static func multiply<S: Sequence>(_ elements: S) -> Self where S.Element == Self {
        elements.reduce(.identity){ (res, e) in res * e }
    }
}

public extension Sequence where Element: Monoid {
    @inlinable
    func multiply() -> Element {
        Element.multiply(self)
    }
}

public extension Sequence {
    @inlinable
    func multiply<M: Monoid>(mapping f: (Element) -> M) -> M {
        M.multiply( map(f) )
    }
}

public protocol Submonoid: Monoid, Subset where Super: Monoid {}

public extension Submonoid {
    static var identity: Self {
        Self(Super.identity)
    }
    
    static func * (a: Self, b: Self) -> Self {
        Self(a.asSuper * b.asSuper)
    }
    
    var inverse: Self? {
        asSuper.inverse.map{ Self($0) }
    }
}

public protocol ProductMonoid: ProductSet, Monoid where Left: Monoid, Right: Monoid {}

public extension ProductMonoid {
    static func * (a: Self, b: Self) -> Self {
        Self(a.left * b.left, a.right * b.right)
    }
    
    static var identity: Self {
        Self(.identity, .identity)
    }
    
    var inverse: Self? {
        if let lInv = left.inverse, let rInv = right.inverse {
            return Self(lInv, rInv)
        } else {
            return nil
        }
    }
}

extension Pair: Multiplicative, Monoid, ProductMonoid where Left: Monoid, Right: Monoid {}

public protocol MonoidHomType: MapType where Domain: Monoid, Codomain: Monoid {}

// MEMO: Mathematically, a map does not automatically become
//       monoid Hom when its domain and codomain are monoids.
extension Map: MonoidHomType where Domain: Monoid, Codomain: Monoid {}

public typealias MonoidHom<Domain: Monoid, Codomain: Monoid> = Map<Domain, Codomain>
public typealias MonoidEnd<Domain: Monoid> = MonoidHom<Domain, Domain>
