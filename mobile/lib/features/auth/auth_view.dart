import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_fonts.dart';
import 'package:mobile/features/auth/components/ghost_button.dart';
import 'package:mobile/features/auth/components/labeled_text_field.dart';
import 'package:mobile/features/auth/components/primary_button.dart';
import 'package:mobile/features/auth/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> { 
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final error = vm.error;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 82, 30, 42),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BILETFLOW",
                style: TextStyle(
                  fontFamily: AppFonts.condensedFamily,
                  fontSize: 12,
                  letterSpacing: 0.22 * 12,
                  color: AppColors.accent700,
                ),
              ),
              
              SizedBox(height: 44),
              
              Text(
                "Scanner\nsign-in",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppFonts.condensedFamily,
                  fontSize: 34,
                  letterSpacing: 1.02,
                  height: 0.95
                ),
              ),
              
              SizedBox(height: 10),
              
              Text(
                "For event administrators authorized by an organizer.",
                style: TextStyle(
                  fontFamily: AppFonts.bodyFamily,
                  fontSize: 13,
                  color: AppColors.neutral700
                )
              ),

              SizedBox(height: 38),

              LabeledTextField(
                label: "Email",
                keyboardType: TextInputType.emailAddress,
                controller: _email,
                hintText: "example@google.com",
                textInputAction: .next,
                onChanged: vm.setEmail,
              ),

              SizedBox(height: 18),
              
              LabeledTextField(
                label: "Password",
                keyboardType: TextInputType.visiblePassword,
                controller: _password,
                isObscure: true,
                hintText: "Password",
                textInputAction: .done,
                onChanged: vm.setPassword
              ),
              
              SizedBox(height: 26),

              if(error != null)...[
                Text(
                  error, 
                  style: TextStyle(
                    fontFamily: AppFonts.bodyFamily, 
                    fontSize: 13,
                    color: Colors.red
                  )
                ),

                const SizedBox(height: 10),
              ],
              PrimaryButton(
                label: vm.isLoading ? 'SIGNING IN...' : 'SIGN IN', 
                onPressed: vm.canSubmit ? _submit : null
              ),

              SizedBox(height: 6),

              GhostButton(label: 'Forgot Password', onPressed: () {} )
            ]
          ),  
        )
      )
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await context.read<AuthViewModel>().signIn();
  }
}