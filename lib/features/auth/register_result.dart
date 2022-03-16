class RegisterResult {
  final String? token;
  final AuthenticationResult? authResult;

  const RegisterResult(this.token, this.authResult);
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
}
