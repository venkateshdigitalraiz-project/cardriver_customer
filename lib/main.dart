import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DriverCustomerApp());
}

class DriverCustomerApp extends StatefulWidget {
  const DriverCustomerApp({super.key});

  @override
  State<DriverCustomerApp> createState() => _DriverCustomerAppState();
}

class _DriverCustomerAppState extends State<DriverCustomerApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Setup Clean Architecture dependencies
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
    final loginWithEmailUseCase = LoginWithEmailUseCase(authRepository);
    final loginWithPhoneUseCase = LoginWithPhoneUseCase(authRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(
            loginWithEmailUseCase: loginWithEmailUseCase,
            loginWithPhoneUseCase: loginWithPhoneUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Car Driver Partner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: LoginPage(
          onToggleTheme: _toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark,
        ),
      ),
    );
  }
}
