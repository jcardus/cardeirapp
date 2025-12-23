class CloudflareConfig {
  // Cloudflare Account ID from --dart-define
  static const String accountId = String.fromEnvironment(
    'CLOUDFLARE_ACCOUNT_ID',
    defaultValue: '53b1e246a278dc3b175ca615904cf34e',
  );

  // Cloudflare API Token from --dart-define
  static const String apiToken = String.fromEnvironment(
    'CLOUDFLARE_API_TOKEN',
    defaultValue: '',
  );

  // SMS Gateway URL from --dart-define
  static const String gwUrl = String.fromEnvironment(
    'SMS_GATEWAY_URL',
    defaultValue: 'https://natal.joaquim.workers.dev',
  );

  // SMS Gateway Token from --dart-define
  static const String gwToken = String.fromEnvironment(
    'SMS_GATEWAY_TOKEN',
    defaultValue: '',
  );

  // Phone number to send SMS to from --dart-define
  static const String phoneNumber = String.fromEnvironment(
    'PHONE_NUMBER',
    defaultValue: '+351912381488',
  );

  // Cloudflare Worker URL for web uploads (bypasses CORS)
  static const String workerUrl = String.fromEnvironment(
    'IMAGE_WORKER_URL',
    defaultValue: '',
  );

  // Cloudflare Images API endpoint (for mobile apps)
  static String get uploadEndpoint =>
      'https://api.cloudflare.com/client/v4/accounts/$accountId/images/v1';

  // Get the appropriate upload endpoint based on platform
  static String getUploadEndpoint({required bool isWeb}) {
    // For web, use the worker if available, otherwise fall back to direct API
    if (isWeb && workerUrl.isNotEmpty) {
      return workerUrl;
    }
    return uploadEndpoint;
  }
}
