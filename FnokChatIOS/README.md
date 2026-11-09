# FNOK Chat pro iPhone

Aplikace vyžaduje iOS 16 nebo novější. Chat otevírá v aplikaci, externí odkazy předává systému a o kameru a mikrofon žádá při jejich použití. Google přihlášení stále vyžaduje úpravu přihlašování na webu FNOK Chatu. Push oznámení vyžadují propojení serveru s Apple Push Notification service.

## Spuštění GitHub Actions

1. Nahraj složku `FnokChatIOS` a soubor `.github/workflows/fnokchat-ios.yml` na výchozí větev repozitáře na GitHubu. Soubor workflow patří do `.github/workflows` v kořeni repozitáře.
2. Otevři **Actions → FNOK Chat iPhone → Run workflow**.
3. Pro první ověření nech volbu **Export a signed IPA for registered iPhones** vypnutou. Výsledný artefakt **FnokChat-Simulator** je určen pro simulátor Xcode na Macu.

[Ruční spuštění workflow v dokumentaci GitHubu](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)

## Instalační IPA pro skutečný iPhone

1. V Apple Developer Program zaregistruj iPhone podle UDID a vytvoř explicitní App ID. Workflow převezme Bundle ID z profilu, takže můžeš použít vlastní dostupný identifikátor.
2. Vytvoř certifikát **Apple Distribution**, vyexportuj ho včetně soukromého klíče jako zaheslovaný `.p12` a vytvoř profil **Ad Hoc** pro stejné App ID, certifikát a cílový iPhone.
3. V GitHubu otevři **Settings → Secrets and variables → Actions → New repository secret** a přidej tyto tři hodnoty.

   - `IOS_CERTIFICATE_BASE64` obsahuje soubor `.p12` zakódovaný do Base64.
   - `IOS_CERTIFICATE_PASSWORD` obsahuje heslo k souboru `.p12`.
   - `IOS_PROFILE_BASE64` obsahuje soubor `.mobileprovision` zakódovaný do Base64.

   V PowerShellu získáš Base64 příkazem:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path '.\distribution.p12').Path))
   [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path '.\profile.mobileprovision').Path))
   ```

   Certifikát, profil ani heslo neukládej do repozitáře.
4. Spusť workflow se zapnutou volbou **Export a signed IPA for registered iPhones**. Po dokončení otevři běh a v **Artifacts** stáhni **FnokChat-iPhone-IPA**. ZIP obsahuje `FnokChat.ipa`.
5. Na registrovaný iPhone nainstaluj IPA přes **Xcode → Window → Devices and Simulators** nebo **Apple Configurator** na Macu. Na telefonu zapni režim vývojáře podle pokynů iOS.

[Vytvoření profilu Ad Hoc](https://developer.apple.com/help/account/provisioning-profiles/create-an-ad-hoc-provisioning-profile/) · [Instalace na registrovaná zařízení](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices)
