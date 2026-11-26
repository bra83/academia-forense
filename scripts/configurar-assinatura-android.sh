#!/usr/bin/env bash
set -euo pipefail
umask 077
repo=bra83/academia-forense
dir="$HOME/.academia-signing"
key="$dir/academia-release.p12"
for tool in gh openssl base64; do
  command -v "$tool" >/dev/null || { echo "Ferramenta ausente: $tool"; exit 1; }
done
gh auth status --hostname github.com
existing="$(gh secret list --repo "$repo" --app actions --json name --jq '.[].name')"
count=0
for name in ACADEMIA_KEYSTORE_B64 ACADEMIA_KEYSTORE_PASSWORD ACADEMIA_KEY_ALIAS ACADEMIA_KEY_PASSWORD; do
  if grep -Fxq "$name" <<< "$existing"; then count=$((count+1)); fi
done
if [ "$count" -eq 4 ]; then
  echo "Os quatro segredos já existem. Nenhuma chave foi alterada."
  exit 0
fi
if [ "$count" -gt 0 ] && [ ! -f "$key" ]; then
  echo "Existem segredos parciais, mas a chave local não foi encontrada. Não será criada outra chave."
  exit 1
fi
mkdir -p "$dir"
read -rsp "Senha da chave (ao menos 12 caracteres; guarde em seu gerenciador de senhas): " ACADEMIA_PASS
echo
[ "$(printf %s "$ACADEMIA_PASS" | wc -c)" -ge 12 ] || { echo "Senha curta."; exit 1; }
read -rsp "Confirme a senha: " confirm
echo
[ "$confirm" = "$ACADEMIA_PASS" ] || { echo "Senhas diferentes."; exit 1; }
unset confirm
export ACADEMIA_PASS
tmp=""
cleanup() {
  if [ -n "$tmp" ]; then rm -rf -- "$tmp"; fi
  unset ACADEMIA_PASS
}
trap cleanup EXIT
if [ ! -f "$key" ]; then
  tmp="$(mktemp -d "$dir/.create.XXXXXXXX")"
  openssl req -new -x509 -newkey rsa:3072 -sha256 -days 10000 \
    -subj "/CN=Academia Forense" \
    -keyout "$tmp/private.pem" -out "$tmp/cert.pem" \
    -passout env:ACADEMIA_PASS
  openssl pkcs12 -export -name academia \
    -inkey "$tmp/private.pem" -in "$tmp/cert.pem" \
    -passin env:ACADEMIA_PASS -passout env:ACADEMIA_PASS \
    -out "$tmp/academia.p12"
  openssl pkcs12 -in "$tmp/academia.p12" -noout -passin env:ACADEMIA_PASS
  mv -- "$tmp/academia.p12" "$key"
fi
# Preserve existing keys. Wrong password or damaged file must not trigger rotation.
openssl pkcs12 -in "$key" -noout -passin env:ACADEMIA_PASS
# Send via stdin. Never print passwords, upload key to Git or rotate an existing complete set.
base64 -w0 "$key" | gh secret set ACADEMIA_KEYSTORE_B64 --app actions --repo "$repo"
printf %s "$ACADEMIA_PASS" | gh secret set ACADEMIA_KEYSTORE_PASSWORD --app actions --repo "$repo"
printf %s academia | gh secret set ACADEMIA_KEY_ALIAS --app actions --repo "$repo"
printf %s "$ACADEMIA_PASS" | gh secret set ACADEMIA_KEY_PASSWORD --app actions --repo "$repo"
echo "Assinatura configurada. Chave privada guardada em: $key"
echo "Faça uma cópia segura da chave e guarde a senha separadamente. Não envie a chave ao chat nem ao GitHub público."
gh secret list --repo "$repo" --app actions
