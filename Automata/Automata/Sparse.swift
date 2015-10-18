
protocol SparseType {
    typealias Key: Hashable
    typealias Value
    func getValue(forKey key: Key) throws -> Value
}

protocol MutableSparseType: SparseType {
    mutating func setValue(newValue: Value, forKey key: Key)
}

struct Sparse<Key: Hashable, Value>: MutableSparseType {
    let defaultTransform: Key throws -> Value
    private var backing = [Key : Value]()
    
    init(defaultTransform: Key throws -> Value) {
        self.defaultTransform = defaultTransform
    }
    
    init(defaultValue: Value) {
        self.init(defaultTransform: { _ in defaultValue })
    }
    
    func getValue(forKey key: Key) throws -> Value {
            return try backing[key] ?? defaultTransform(key)
    }

    mutating func setValue(newValue: Value, forKey key: Key) {
        backing[key] = newValue
    }
}

extension Sparse where Value: Equatable {
    mutating func setValue(newValue: Value, forKey key: Key) {
        do {
            if try newValue == defaultTransform(key) {
                backing.removeValueForKey(key)
                return
            }
        }
        catch { }
        backing[key] = newValue
    }
}

protocol Defaultable {
    static func defaultValue() -> Self
}

extension Optional: Defaultable {
    static func defaultValue() -> Optional { return nil }
}

extension Sparse where Value: Defaultable {
    init() {
        self.init(defaultValue: Value.defaultValue())
    }
}

extension Sparse {
    func map<MappedValue>(transform: Value -> MappedValue) -> SparseView<Key, MappedValue> {
        return SparseView { key in transform(try self.getValue(forKey: key)) }
    }
}

struct SparseView<Key: Hashable, Value>: SparseType {
    private let getValueForKey: Key throws -> Value
    
    init<S: SparseType where S.Key == Key, S.Value == Value>(_ sparse: S) {
        getValueForKey = sparse.getValue
    }
    
    init(getValueForKey: Key throws -> Value) {
        self.getValueForKey = getValueForKey
    }
    
    func getValue(forKey key: Key) throws -> Value {
        return try getValueForKey(key)
    }
}

