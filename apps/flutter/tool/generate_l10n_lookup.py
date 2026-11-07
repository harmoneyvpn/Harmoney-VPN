#!/usr/bin/env python3
"""Generate the ARB key adapter and source-template maps."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / "lib/l10n/app_en.arb").read_text(encoding="utf-8"))
prefixes = ("inlineText_", "inlineAttribute_", "inlineTextTemplate_", "inlineAttributeTemplate_", "directFa_", "directEn_", "directFaTemplate_", "directEnTemplate_")
keys = [key for key in data if key.startswith(prefixes)]
def dart(value):
    return json.dumps(value, ensure_ascii=False).replace("$", r"\$")
lines = ["// Generated from app_en.arb by tool/generate_l10n_lookup.py.", "// Translation values are stored in ARB files.", "import 'app_localizations.dart';", ""]
for name, prefix in (("inlineTextTemplateKeys", "inlineTextTemplate_"), ("inlineAttributeTemplateKeys", "inlineAttributeTemplate_"), ("directFaTemplateKeys", "directFaTemplate_"), ("directEnTemplateKeys", "directEnTemplate_")):
    lines.append(f"const Map<String, String> {name} = <String, String>{{")
    for key in sorted(keys, key=lambda k: len(data[k]), reverse=True):
        if key.startswith(prefix):
            lines.append(f"  {dart(data.get('@' + key, {}).get('sourcePattern', data[key]))}: {dart(key)},")
    lines += ["};", ""]
lines += ["String? appLocalizationsInlineValue(AppLocalizations l10n, String key) =>", "    switch (key) {"]
for key in keys:
    lines.append(f"      {dart(key)} => l10n.{key},")
lines += ["      _ => null,", "    };"]
(ROOT / "lib/l10n/app_localizations_lookup.dart").write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Generated lookup for {len(keys)} ARB keys.")
