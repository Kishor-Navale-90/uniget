/// Public surface of the Asset Management feature. See this
/// package's README for the full layer-by-layer walkthrough — it's
/// the copy-paste template for every other feature module.
library feature_asset_management;

export 'src/domain/entities/asset.dart';
export 'src/domain/entities/asset_status.dart';
export 'src/domain/repositories/asset_repository.dart';
export 'src/presentation/bloc/asset_list/asset_list_bloc.dart';
export 'src/presentation/bloc/asset_list/asset_list_event.dart';
export 'src/presentation/bloc/asset_list/asset_list_state.dart';
export 'src/presentation/bloc/asset_transfer/asset_transfer_bloc.dart';
export 'src/presentation/bloc/asset_transfer/asset_transfer_event.dart';
export 'src/presentation/bloc/asset_transfer/asset_transfer_state.dart';
export 'src/presentation/pages/asset_list_page.dart';
export 'src/presentation/pages/asset_detail_page.dart';
export 'src/di/asset_injection.dart';
export 'src/di/asset_injection.module.dart';
