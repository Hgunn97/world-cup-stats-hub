import 'package:flutter/material.dart';

// Maps FIFA 3-letter country codes to flagcdn.com ISO codes.
// flagcdn.com uses ISO 3166-1 alpha-2 (lowercase), with regional variants
// for nations without standalone ISO codes (e.g. gb-sct for Scotland).
const Map<String, String> _fifaToIso = {
  'MEX': 'mx', 'CZE': 'cz', 'RSA': 'za', 'KOR': 'kr',
  'CAN': 'ca', 'BIH': 'ba', 'QAT': 'qa', 'SUI': 'ch',
  'BRA': 'br', 'HAI': 'ht', 'MAR': 'ma', 'SCO': 'gb-sct',
  'USA': 'us', 'AUS': 'au', 'PAR': 'py', 'TUR': 'tr',
  'CUW': 'cw', 'ECU': 'ec', 'GER': 'de', 'CIV': 'ci',
  'NED': 'nl', 'JPN': 'jp', 'SWE': 'se', 'TUN': 'tn',
  'BEL': 'be', 'EGY': 'eg', 'IRN': 'ir', 'NZL': 'nz',
  'CPV': 'cv', 'KSA': 'sa', 'ESP': 'es', 'URU': 'uy',
  'FRA': 'fr', 'NOR': 'no', 'SEN': 'sn', 'IRQ': 'iq',
  'ALG': 'dz', 'ARG': 'ar', 'AUT': 'at', 'JOR': 'jo',
  'COL': 'co', 'COD': 'cd', 'POR': 'pt', 'UZB': 'uz',
  'CRO': 'hr', 'ENG': 'gb-eng', 'GHA': 'gh', 'PAN': 'pa',
};

String? isoCode(String? fifaCode) =>
    fifaCode == null ? null : _fifaToIso[fifaCode.toUpperCase()];

class TeamFlag extends StatelessWidget {
  final String? countryCode;
  final double height;

  const TeamFlag({super.key, required this.countryCode, this.height = 16});

  @override
  Widget build(BuildContext context) {
    final iso = isoCode(countryCode);
    if (iso == null) return SizedBox(width: height * 1.33, height: height);

    // flagcdn.com provides widths: 20, 40, 80, 160, 320, 640, 1280
    final cdnWidth = height <= 14 ? 20 : height <= 28 ? 40 : 80;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.network(
        'https://flagcdn.com/w$cdnWidth/$iso.png',
        height: height,
        width: height * 1.33,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            SizedBox(width: height * 1.33, height: height),
      ),
    );
  }
}
