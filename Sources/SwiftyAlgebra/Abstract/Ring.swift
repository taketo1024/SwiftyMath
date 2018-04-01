import Foundation

public protocol Ring: AdditiveGroup, Monoid {
    init(from: 𝐙)
    var inverse: Self? { get }
    var isInvertible: Bool { get }
    var normalizeUnit: Self { get }
    static var isField: Bool { get }
}

public extension Ring {
    public var isInvertible: Bool {
        return (inverse != nil)
    }
    
    public var normalizeUnit: Self {
        return .identity
    }
    
    public func pow(_ n: Int) -> Self {
        if n >= 0 {
            return (0 ..< n).reduce(.identity){ (res, _) in self * res }
        } else {
            return (0 ..< -n).reduce(.identity){ (res, _) in inverse! * res }
        }
    }
    
    public static var zero: Self {
        return Self(from: 0)
    }
    
    public static var identity: Self {
        return Self(from: 1)
    }
    
    public static var isField: Bool {
        return false
    }
}

public protocol Subring: Ring, AdditiveSubgroup, Submonoid where Super: Ring {}

public extension Subring {
    public init(from n: 𝐙) {
        self.init( Super.init(from: n) )
    }

    public var inverse: Self? {
        return asSuper.inverse.flatMap{ Self.init($0) }
    }
    
    public static var zero: Self {
        return Self.init(from: 0)
    }
    
    public static var identity: Self {
        return Self.init(from: 1)
    }
}

public protocol Ideal: AdditiveSubgroup where Super: Ring {
    static func * (r: Super, a: Self) -> Self
    static func * (m: Self, r: Super) -> Self
    
    static func reduced(_ a: Super) -> Super
    static func inverseInQuotient(_ r: Super) -> Super?
}

public extension Ideal {
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.asSuper * b.asSuper)
    }
    
    public static func * (r: Super, a: Self) -> Self {
        return Self(r * a.asSuper)
    }
    
    public static func * (a: Self, r: Super) -> Self {
        return Self(a.asSuper * r)
    }
}

public protocol MaximalIdeal: Ideal {}

public protocol _ProductRing: Ring, AdditiveProductGroup where Left: Ring, Right: Ring {}

public extension _ProductRing {
    public init(from a: 𝐙) {
        self.init(Left(from: a), Right(from: a))
    }
    
    public var inverse: Self? {
        return _1.inverse.flatMap{ r1 in _2.inverse.flatMap{ r2 in Self(r1, r2) }  }
    }
    
    public static var zero: Self {
        return Self(Left.zero, Right.zero)
    }
    public static var identity: Self {
        return Self(Left.identity, Right.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a._1 * b._1, a._2 * b._2)
    }
}

public struct ProductRing<R1: Ring, R2: Ring>: _ProductRing {
    public typealias Left = R1
    public typealias Right = R2
    
    public let _1: R1
    public let _2: R2
    
    public init(_ r1: R1, _ r2: R2) {
        self._1 = r1
        self._2 = r2
    }
}

public protocol _QuotientRing: Ring, AdditiveQuotientGroup where Sub: Ideal {}

public extension _QuotientRing where Base == Sub.Super {
    public init(from n: 𝐙) {
        self.init(Base(from: n))
    }
    
    public var inverse: Self? {
        return Sub.inverseInQuotient(representative).map{ Self($0) }
    }
    
    public static var zero: Self {
        return Self(.zero)
    }
    
    public static var identity: Self {
        return Self(.identity)
    }
    
    public static func * (a: Self, b: Self) -> Self {
        return Self(a.representative * b.representative)
    }
    
    public var hashValue: Int {
        return representative.hashValue // must assure `representative` is unique.
    }
}

public struct QuotientRing<R, I>: _QuotientRing where I: Ideal, R == I.Super {
    public typealias Sub = I
    
    internal let r: R
    
    public init(_ r: R) {
        self.r = I.reduced(r)
    }
    
    public var representative: R {
        return r
    }
}

// memo `QuotientRing: Field where I: MaximalIdeal` causes error...

extension QuotientRing: EuclideanRing where I: MaximalIdeal {
    public var degree: Int {
        return self == .zero ? 0 : 1
    }
    
    public static func eucDiv(_ a: QuotientRing<R, I>, _ b: QuotientRing<R, I>) -> (q: QuotientRing<R, I>, r: QuotientRing<R, I>) {
        return (a * b.inverse!, .zero)
    }
}

extension QuotientRing: Field where I: MaximalIdeal {}


public protocol _RingHom: Map where Domain: Ring, Codomain: Ring {}

public struct RingHom<X: Ring, Y: Ring>: _RingHom {
    public typealias Domain = X
    public typealias Codomain = Y
    
    private let f: (X) -> Y
    public init(_ f: @escaping (X) -> Y) {
        self.f = f
    }
    
    public func applied(to x: X) -> Y {
        return f(x)
    }
    
    public func composed<W>(with f: RingHom<W, X>) -> RingHom<W, Y> {
        return RingHom<W, Y> { x in self.applied(to: f.applied(to: x)) }
    }
    
    public static func ∘<Z>(g: RingHom<Y, Z>, f: RingHom<X, Y>) -> RingHom<X, Z> {
        return g.composed(with: f)
    }
}
