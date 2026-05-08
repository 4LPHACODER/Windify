class AuthSessionInfo {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime? expiresAt;
  final String userId;

  const AuthSessionInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
    required this.userId,
  });

  String get maskedAccessToken {
    if (accessToken.length <= 12) return '***';
    return '${accessToken.substring(0, 6)}...${accessToken.substring(accessToken.length - 6)}';
  }
}
