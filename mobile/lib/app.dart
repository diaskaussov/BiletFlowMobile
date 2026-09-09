import 'package:flutter/material.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/features/auth/view_model/auth_view_model.dart';
import 'package:mobile/repositories/auth_repository_mock.dart';
import 'package:provider/provider.dart';

class BiletFlowApp extends StatefulWidget {
  const BiletFlowApp({super.key});

  @override
  State<BiletFlowApp> createState() => _BiletFlowAppState();
}

class _BiletFlowAppState extends State<BiletFlowApp> {
  late final AuthViewModel _auth = AuthViewModel(AuthRepositoryMock());
  late final _router = createRouter(_auth);

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'BiletFlow',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}