// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$healthTipsHash() => r'd3b34f10c18f6b2705cf44684c864fe750e0ea02';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [healthTips].
@ProviderFor(healthTips)
const healthTipsProvider = HealthTipsFamily();

/// See also [healthTips].
class HealthTipsFamily extends Family<AsyncValue<List<HealthTip>>> {
  /// See also [healthTips].
  const HealthTipsFamily();

  /// See also [healthTips].
  HealthTipsProvider call({String? category}) {
    return HealthTipsProvider(category: category);
  }

  @override
  HealthTipsProvider getProviderOverride(
    covariant HealthTipsProvider provider,
  ) {
    return call(category: provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'healthTipsProvider';
}

/// See also [healthTips].
class HealthTipsProvider extends AutoDisposeFutureProvider<List<HealthTip>> {
  /// See also [healthTips].
  HealthTipsProvider({String? category})
    : this._internal(
        (ref) => healthTips(ref as HealthTipsRef, category: category),
        from: healthTipsProvider,
        name: r'healthTipsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$healthTipsHash,
        dependencies: HealthTipsFamily._dependencies,
        allTransitiveDependencies: HealthTipsFamily._allTransitiveDependencies,
        category: category,
      );

  HealthTipsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String? category;

  @override
  Override overrideWith(
    FutureOr<List<HealthTip>> Function(HealthTipsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HealthTipsProvider._internal(
        (ref) => create(ref as HealthTipsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<HealthTip>> createElement() {
    return _HealthTipsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HealthTipsProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HealthTipsRef on AutoDisposeFutureProviderRef<List<HealthTip>> {
  /// The parameter `category` of this provider.
  String? get category;
}

class _HealthTipsProviderElement
    extends AutoDisposeFutureProviderElement<List<HealthTip>>
    with HealthTipsRef {
  _HealthTipsProviderElement(super.provider);

  @override
  String? get category => (origin as HealthTipsProvider).category;
}

String _$healthTipDetailHash() => r'2386a07220e7103adca67cb0002e73c1b1bea180';

/// See also [healthTipDetail].
@ProviderFor(healthTipDetail)
const healthTipDetailProvider = HealthTipDetailFamily();

/// See also [healthTipDetail].
class HealthTipDetailFamily extends Family<AsyncValue<HealthTip>> {
  /// See also [healthTipDetail].
  const HealthTipDetailFamily();

  /// See also [healthTipDetail].
  HealthTipDetailProvider call(String id) {
    return HealthTipDetailProvider(id);
  }

  @override
  HealthTipDetailProvider getProviderOverride(
    covariant HealthTipDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'healthTipDetailProvider';
}

/// See also [healthTipDetail].
class HealthTipDetailProvider extends AutoDisposeFutureProvider<HealthTip> {
  /// See also [healthTipDetail].
  HealthTipDetailProvider(String id)
    : this._internal(
        (ref) => healthTipDetail(ref as HealthTipDetailRef, id),
        from: healthTipDetailProvider,
        name: r'healthTipDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$healthTipDetailHash,
        dependencies: HealthTipDetailFamily._dependencies,
        allTransitiveDependencies:
            HealthTipDetailFamily._allTransitiveDependencies,
        id: id,
      );

  HealthTipDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<HealthTip> Function(HealthTipDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HealthTipDetailProvider._internal(
        (ref) => create(ref as HealthTipDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<HealthTip> createElement() {
    return _HealthTipDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HealthTipDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HealthTipDetailRef on AutoDisposeFutureProviderRef<HealthTip> {
  /// The parameter `id` of this provider.
  String get id;
}

class _HealthTipDetailProviderElement
    extends AutoDisposeFutureProviderElement<HealthTip>
    with HealthTipDetailRef {
  _HealthTipDetailProviderElement(super.provider);

  @override
  String get id => (origin as HealthTipDetailProvider).id;
}

String _$healthLogsNotifierHash() =>
    r'39ab0be23a73f8362d3558abe47bbceb1df33bd6';

/// See also [HealthLogsNotifier].
@ProviderFor(HealthLogsNotifier)
final healthLogsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      HealthLogsNotifier,
      List<HealthLog>
    >.internal(
      HealthLogsNotifier.new,
      name: r'healthLogsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$healthLogsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HealthLogsNotifier = AutoDisposeAsyncNotifier<List<HealthLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
