flatpak install flathub org.kde.skrooge

Settings -> Configure Scrooge -> Import/Export -> CSV -> Edit regular expressions

- Date: ^date|^Buchungstag|^Datum|^Booking Date|^Buchungsdatum
- Payee: ^payee|^tiers|^Beguenstigter/Zahlungspflichtiger|^Empfänger|^Partner Name
- Comment: ^comment|^libell?|^d?tail|^info|^Verwendungszweck|^Payment Reference
- Account: ^account|^Auftragskonto
- Amount: ^value|^amount|^valeur|^montant|^credit|^debit|^Betrag|^Betrag (EUR)|^Amount (EUR)
- Unit: ^unit|^Waehrung
