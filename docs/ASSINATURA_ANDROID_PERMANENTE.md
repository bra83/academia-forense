# Assinatura permanente do Academia Forense (Android)

A atualização por cima de uma instalação existente exige o mesmo applicationId
(com.academiaforense.academia_v2), o mesmo certificado de assinatura e um
versionCode compatível. Os builds 129 e 138 foram assinados com chaves de
depuração diferentes. Uma chave nova NÃO pode assinar uma atualização que o
Android aceite sobre esses APKs antigos. Não desinstale antes de salvar seus
dados. Uma migração inicial pode ser inevitável se a chave original não puder
ser recuperada.

A partir desta alteração, o workflow usa uma chave permanente privada via
GitHub Actions Secrets, e versionCode crescente (1000 + número da execução).
Na ausência da chave, o artefato é explicitamente rotulado TESTE. Não é um
APK de atualização.

## Configuração única pelo proprietário

Se tiver a chave original, use-a; caso contrário gere uma nova no computador
privado (não no repositório), com Java keytool:

    keytool -genkeypair -keystore academia-release.jks -storetype PKCS12 -alias academia -keyalg RSA -keysize 3072 -validity 10000

Guarde o arquivo e as senhas num local privado com backup. Configure os quatro
secrets em Settings > Secrets and variables > Actions > Repository secrets:
ACADEMIA_KEYSTORE_B64 (base64 do arquivo), ACADEMIA_KEYSTORE_PASSWORD,
ACADEMIA_KEY_ALIAS, ACADEMIA_KEY_PASSWORD.

No PowerShell, com GitHub CLI autenticado e o arquivo no diretório atual:
    [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path .\academia-release.jks))) | gh secret set ACADEMIA_KEYSTORE_B64 --repo bra83/academia-forense
    gh secret set ACADEMIA_KEYSTORE_PASSWORD --repo bra83/academia-forense
    gh secret set ACADEMIA_KEY_ALIAS --repo bra83/academia-forense
    gh secret set ACADEMIA_KEY_PASSWORD --repo bra83/academia-forense

O alias do exemplo é academia. Não cole segredos no chat, em commits, logs ou
issues. Se a chave for PKCS12, use a mesma senha para store e key.
Não altere a chave nas próximas compilações.

## Validação de atualização

Após configurar, execute o workflow e confira que o artefato se chama
Academia-Forense-A57-Android-Verified. Compare o certificado dos próximos dois
APKs com apksigner verify --print-certs e verifique versionCode crescente.
Teste instalação por cima sem desinstalar e preservação de conteúdo, notas,
marcadores e preferências. O workflow não comprova sozinho migração no aparelho.

## Configuração pelo Android (Termux)

O script `scripts/configurar-assinatura-android.sh` configura os quatro segredos via GitHub CLI, usando um JDK instalado que forneça `keytool`. Após a configuração, uma nova execução do workflow deve gerar o artefato `Academia-Forense-A57-Android-Verified`. Se o nome incluir `TESTE-sem-assinatura-permanente`, a chave não foi aplicada. Não desinstale o APK anterior para testar esse artefato.
