# Tracciamento lavoro squadra

PWA installabile per pianificare le attività giornaliere di una squadra senza digitare le mansioni a mano. Ogni casella del calendario apre una selezione a checkbox; la dashboard produce percentuali settimanali, mensili e annuali per operatore.

## Funzioni

- calendario settimanale ottimizzato per telefono e desktop;
- selezione multipla delle attività tramite checkbox;
- operatori e attività modificabili;
- dashboard con un grafico per ogni operatore;
- dati salvati localmente, funzionamento offline e backup JSON;
- installazione come app Android dalla schermata Home;
- nessun database o account richiesto per il prototipo.

## Avvio locale

Richiede Node.js 20 o successivo.

```bash
npm run dev
```

Aprire `http://localhost:4173`. Per installarla su Android, pubblicarla su HTTPS, aprirla con Chrome e scegliere **Installa app** o **Aggiungi a schermata Home**.

## Test

```bash
npm test
npm run check
```

## Dati e sincronizzazione

Questa prima versione usa `localStorage`: i dati restano nel browser del singolo dispositivo. Il backup si esporta e importa dalle Impostazioni. Per l’uso contemporaneo da più telefoni, la fase successiva prevede autenticazione e database condiviso (Supabase o Firebase).

## Struttura

- `app.js`: interfaccia e flussi utente;
- `analytics.js`: periodi, conteggi e percentuali;
- `storage.js`: persistenza e validazione backup;
- `sw.js` e `manifest.webmanifest`: installazione e uso offline;
- `test/`: test automatici senza dipendenze esterne.

