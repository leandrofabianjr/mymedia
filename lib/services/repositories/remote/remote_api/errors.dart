class RemoteApiException implements Exception {
  final String message;
  const RemoteApiException(this.message);

  @override
  String toString() => message;
}

class RemoteApiUsernameOrPasswordInvalidException extends RemoteApiException {
  const RemoteApiUsernameOrPasswordInvalidException()
    : super('Usuário ou senha inválidos.');
}
