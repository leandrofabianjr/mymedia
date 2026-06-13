class RemoteAuthToken {
  final String accessToken;
  final String tokenType;

  RemoteAuthToken({required this.accessToken, required this.tokenType});

  factory RemoteAuthToken.fromJson(Map<String, dynamic> json) {
    return RemoteAuthToken(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}
