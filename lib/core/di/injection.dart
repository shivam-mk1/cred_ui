import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../utils/cta_dispatcher.dart';
import '../../data/datasources/card_management_remote_datasource.dart';
import '../../data/repositories/card_management_repository_impl.dart';
import '../../domain/repositories/card_management_repository.dart';
import '../../domain/usecases/fetch_card_management_usecase.dart';
import '../../presentation/card_management/cubit/card_management_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerLazySingleton<DioClient>(DioClient.new);

  sl.registerLazySingleton<CtaDispatcher>(CtaDispatcherImpl.new);

  sl.registerLazySingleton<CardManagementRemoteDatasource>(
    () => CardManagementRemoteDatasource(sl<DioClient>().dio),
  );

  sl.registerLazySingleton<CardManagementRepository>(
    () => CardManagementRepositoryImpl(sl<CardManagementRemoteDatasource>()),
  );

  sl.registerLazySingleton<FetchCardManagementUseCase>(
    () => FetchCardManagementUseCase(sl<CardManagementRepository>()),
  );

  sl.registerFactory<CardManagementCubit>(
    () => CardManagementCubit(sl<FetchCardManagementUseCase>()),
  );
}
