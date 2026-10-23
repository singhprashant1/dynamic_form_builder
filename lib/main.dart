import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/json_data_source.dart';
import 'data/menu_repository_impl.dart';
import 'domain/menu_repository.dart';
import 'presentation/cubit/menu_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(App(repository: MenuRepositoryImpl(JsonDataSource(rootBundle))));
}

class App extends StatelessWidget {
  final MenuRepository repository;

  const App({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuCubit(repository)..load(),
      child: MaterialApp(
        title: 'Dynamic Form Builder',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const HomePage(),
      ),
    );
  }
}
