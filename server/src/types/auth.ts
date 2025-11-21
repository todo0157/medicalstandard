export interface AuthTokenPayload {
  sub: string; // account id
  profileId: string;
  provider: string;
  email: string;
}

export interface AuthResult {
  token: string;
  refreshToken: string;
  profileId: string;
  accountId: string;
}
