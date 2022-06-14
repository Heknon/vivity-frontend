import 'package:vivity/features/auth/models/token_container.dart';


/// When tokenContainer is null authentication is considered a failure
class AuthenticationResult {
  final TokenContainer? tokenContainer;
  final AuthenticationStatus? authStatus;

//<editor-fold desc="Data Methods">

  const AuthenticationResult({
    this.tokenContainer,
    this.authStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthenticationResult && runtimeType == other.runtimeType && tokenContainer == other.tokenContainer && authStatus == other.authStatus);

  @override
  int get hashCode => tokenContainer.hashCode ^ authStatus.hashCode;

  @override
  String toString() {
    return 'AuthenticationResult{' + ' tokenContainer: $tokenContainer,' + ' authStatus: $authStatus,' + '}';
  }

  AuthenticationResult copyWith({
    TokenContainer? tokenContainer,
    AuthenticationStatus? authStatus,
  }) {
    return AuthenticationResult(
      tokenContainer: tokenContainer ?? this.tokenContainer,
      authStatus: authStatus ?? this.authStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tokenContainer': this.tokenContainer,
      'authStatus': this.authStatus,
    };
  }

  factory AuthenticationResult.fromMap(Map<String, dynamic> map) {
    return AuthenticationResult(
      tokenContainer: map['tokenContainer'] as TokenContainer,
      authStatus: map['authStatus'] as AuthenticationStatus,
    );
  }

//</editor-fold>
}

enum AuthenticationStatus {
  tokenInvalid,
  emailExists,
  passwordIncorrect,
  presentInBlacklist,
  success,
  notBusiness,
  missingFields,
  emailIncorrect,
  passwordInvalid,
  emailInvalid,
  wrongOTP,
  tooManyAttempts
}

extension AuthResultMessages on AuthenticationStatus {
  String getMessage() {
    switch (this) {
      case AuthenticationStatus.tokenInvalid:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.emailExists:
        return "A user with this email already exists";
      case AuthenticationStatus.passwordIncorrect:
        return "Incorrect details";
      case AuthenticationStatus.presentInBlacklist:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.success:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.notBusiness:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.missingFields:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.emailIncorrect:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.passwordInvalid:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.emailInvalid:
        // TODO: Handle this case.
        break;
      case AuthenticationStatus.wrongOTP:
        return "Wrong OTP. Try again.";
      case AuthenticationStatus.tooManyAttempts:
        return "You've made too many attempts in the past 5 minutes.\nPlease wait.";
    }

    return "Incorrect details";
  }
}
