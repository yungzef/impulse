import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final GSIButtonConfiguration? configuration;

  const GoogleSignInButton({
    required this.onPressed,
    this.configuration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebButton();
    } else {
      return _buildMobileButton(context);
    }
  }

  Widget _buildWebButton() {
    return renderButton(
      configuration: configuration ?? GSIButtonConfiguration(
        type: GSIButtonType.standard,
        theme: GSIButtonTheme.outline,
        size: GSIButtonSize.large,
        text: GSIButtonText.signinWith,
        shape: GSIButtonShape.rectangular,
        logoAlignment: GSIButtonLogoAlignment.left,
      ),
    );
  }

  Widget _buildMobileButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          const Text('Войти с Google'),
        ],
      ),
    );
  }
}