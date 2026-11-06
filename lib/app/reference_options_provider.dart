import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

part 'reference_options_provider.g.dart';

/// Active income sources the transaction form can offer.
///
/// It lives in the composition layer so the transactions feature never imports
/// the income sources feature.
@Riverpod(keepAlive: true)
Stream<List<ReferenceInfo>> activeIncomeSourceOptions(Ref ref) => ref
    .watch(incomeSourceRepositoryProvider)
    .watchActive()
    .map(
      (sources) => [
        for (final source in sources)
          ReferenceInfo(
            id: source.id,
            name: source.name,
            colorValue: source.colorValue,
            isArchived: false,
          ),
      ],
    );

/// Active categories the transaction form can offer.
@Riverpod(keepAlive: true)
Stream<List<ReferenceInfo>> activeCategoryOptions(Ref ref) => ref
    .watch(categoryRepositoryProvider)
    .watchActive()
    .map(
      (categories) => [
        for (final category in categories)
          ReferenceInfo(
            id: category.id,
            name: category.name,
            colorValue: category.colorValue,
            isArchived: false,
          ),
      ],
    );
