import 'auth_result.dart';

class RegisterResult {
  final AuthResult? authResult;
  final AuthenticationResult? authStatus;

//<editor-fold desc="Data Methods">

  const RegisterResult({
    this.authResult,
    this.authStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegisterResult && runtimeType == other.runtimeType && authResult == other.authResult && authStatus == other.authStatus);

  @override
  int get hashCode => authResult.hashCode ^ authStatus.hashCode;

  @override
  String toString() {
    return 'RegisterResult{' + ' authResult: $authResult,' + ' authStatus: $authStatus,' + '}';
  }

  RegisterResult copyWith({
    AuthResult? authResult,
    AuthenticationResult? authStatus,
  }) {
    return RegisterResult(
      authResult: authResult ?? this.authResult,
      authStatus: authStatus ?? this.authStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authResult': this.authResult,
      'authStatus': this.authStatus,
    };
  }

  factory RegisterResult.fromMap(Map<String, dynamic> map) {
    return RegisterResult(
      authResult: map['authResult'] as AuthResult,
      authStatus: map['authStatus'] as AuthenticationResult,
    );
  }

//</editor-fold>
}

enum AuthenticationResult {
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

extension AuthResultMessages on AuthenticationResult {
  String getMessage() {
    switch (this) {
      case AuthenticationResult.tokenInvalid:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.emailExists:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.passwordIncorrect:
        return "Incorrect details";
      case AuthenticationResult.presentInBlacklist:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.success:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.notBusiness:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.missingFields:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.emailIncorrect:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.passwordInvalid:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.emailInvalid:
        // TODO: Handle this case.
        break;
      case AuthenticationResult.wrongOTP:
        return "Wrong OTP. Try again.";
      case AuthenticationResult.tooManyAttempts:
        return "You've made too many attempts in the past 5 minutes.\nPlease wait.";
    }

    return "Incorrect details";
  }
}
