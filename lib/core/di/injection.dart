import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../features/dynamic_form/data/repositories/mock_form_repository.dart';
import '../../features/dynamic_form/domain/entities/form_config.dart';
import '../../features/dynamic_form/domain/repositories/form_repository.dart';
import '../../features/dynamic_form/domain/usecases/submit_form.dart';
import '../../features/dynamic_form/domain/usecases/validate_form.dart';
import '../../features/dynamic_form/domain/validators/field_validator.dart';
import '../../features/dynamic_form/presentation/bloc/dynamic_form_bloc.dart';
import '../../features/dynamic_form/presentation/widgets/field_builders.dart';
import '../../features/menu/data/datasources/menu_data_source.dart';
import '../../features/menu/data/models/config_mapper.dart';
import '../../features/menu/data/repositories/menu_repository_impl.dart';
import '../../features/menu/domain/repositories/menu_repository.dart';
import '../../features/menu/domain/usecases/get_app_config.dart';
import '../../features/menu/domain/usecases/get_workspaces.dart';
import '../../features/menu/presentation/bloc/menu_bloc.dart';

/// Service locator. The only place concrete implementations are chosen.
final sl = GetIt.instance;

void configureDependencies() {
  // Menu — data
  sl
    ..registerLazySingleton<MenuDataSource>(
      () => AssetMenuDataSource(rootBundle),
    )
    ..registerLazySingleton(() => const ConfigMapper())
    ..registerLazySingleton<MenuRepository>(
      () => MenuRepositoryImpl(sl(), sl()),
    )
    // Menu — domain / presentation
    ..registerLazySingleton(() => GetWorkspaces(sl()))
    ..registerLazySingleton(() => GetAppConfig(sl()))
    ..registerFactory(() => MenuBloc(sl(), sl()))
    // Dynamic form — data (swap for an HTTP repository when the API exists)
    ..registerLazySingleton<FormRepository>(MockFormRepository.new)
    // Dynamic form — domain
    ..registerLazySingleton(
      () => const ValidateForm([
        RequiredValidator(),
        MinLengthValidator(),
        MaxLengthValidator(),
        EmailValidator(),
        PatternValidator(),
      ]),
    )
    ..registerLazySingleton(() => SubmitForm(sl()))
    // Dynamic form — presentation
    ..registerLazySingleton(
      () => const FieldBuilderRegistry([TextFieldBuilder()]),
    )
    ..registerFactoryParam<DynamicFormBloc, FormConfig, void>(
      (form, _) =>
          DynamicFormBloc(form: form, validateForm: sl(), submitForm: sl()),
    );
}
