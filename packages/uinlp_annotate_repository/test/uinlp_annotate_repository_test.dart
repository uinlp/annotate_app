import 'package:flutter_test/flutter_test.dart';

import 'package:uinlp_annotate_repository/uinlp_annotate_repository.dart';

void main() {
  test('adds one to input values', () async {
    final repo = UinlpAnnotateRepositoryProd(baseUrl: "");
    print(await repo.getRecentAssets());
    expect(1 + 1, 2);
  });
}
