final RegExp validEmail = RegExp(r'^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$');
final RegExp upperAndLowerCaseRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])');
final RegExp specialCharactersRegex = RegExp(r'^(?=.*[^a-zA-Z0-9])');
final RegExp numbersRegex = RegExp(r'^(?=.*\d)');
final RegExp securePasswordRegex = RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[^a-zA-Z0-9]).{8,100}$');
