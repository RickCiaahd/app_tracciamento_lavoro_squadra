# Squadra Tracker — Android

App Flutter offline per assegnare più attività giornaliere agli operatori tramite checkbox e visualizzare report settimanali, mensili e annuali.

## Scaricare l’APK

Ogni aggiornamento avvia il workflow **Android APK**. Aprire la relativa esecuzione nella scheda **Actions**, scaricare l’artifact `squadra-tracker-apk`, estrarre lo ZIP e inviare `app-release.apk` al telefono.

Sul telefono potrebbe essere necessario autorizzare temporaneamente l’installazione di app provenienti dal browser o dal gestore file. Gli aggiornamenti firmati in modo coerente possono essere installati sopra la versione precedente conservando i dati.

## Funzioni

- calendario settimanale con operatori sulle righe e giorni sulle colonne;
- multiselezione delle attività con checkbox;
- gestione modificabile di operatori e attività;
- report settimanali, mensili e annuali con percentuali e grafico per operatore;
- persistenza offline sul dispositivo tramite SharedPreferences;
- backup JSON copiabile e importabile dagli appunti;
- nessun server, login o connessione Internet richiesti dopo l’installazione.

## Sviluppo locale

Richiede Flutter stable e Android Studio/Android SDK.

```bash
flutter create --platforms=android --org it.rickciaahd --project-name squadra_tracker .
flutter pub get
flutter run
```

Per creare manualmente l’APK:

```bash
flutter build apk --release
```

Il file sarà in `build/app/outputs/flutter-apk/app-release.apk`.

## Verifiche

```bash
flutter analyze
flutter test
```

