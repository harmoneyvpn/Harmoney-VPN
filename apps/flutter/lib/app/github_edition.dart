/// Build constants for the public source edition.
///
/// The public GitHub Pages download page for Harmoney Pro.
abstract final class GithubEdition {
  static const harmoneyProDownloadUrl = String.fromEnvironment(
    'HARMONEY_PRO_DOWNLOAD_URL',
    defaultValue: 'https://harmoneyvpn.github.io/Harmoney-VPN/',
  );

  static bool get hasHarmoneyProDownload =>
      harmoneyProDownloadUrl.trim().isNotEmpty;

  static const allowedProviders = <String>{'harmoney', 'firetunnel'};
}
