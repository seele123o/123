enum ProfileType {
  subscription,
  custom;

  @override
  String toString() {
    return switch (this) {
      subscription => 'subscription',
      custom => 'custom',
    };
  }

  static ProfileType fromString(String value) {
    return switch (value.toLowerCase()) {
      'subscription' => ProfileType.subscription,
      'custom' => ProfileType.custom,
      _ => throw ArgumentError('Invalid ProfileType value: $value'),
    };
  }
}