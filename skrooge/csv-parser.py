#!/usr/env/python3
import argparse
import csv
import sys
import hashlib
import os

def parse_args():
    parser = argparse.ArgumentParser(
        prog='CSV-Parser',
        description='Parses banking statement CSVs and outputs a normed version for scrooge'
    )
    parser.add_argument('input_csv')
    args = parser.parse_args()

    return args


def parse_vwbank(args):
    rows = []

    with open(args.input_csv, newline='') as csvfile:
        # skip first few lines to reach actual table
        [ csvfile.readline() for _ in range(2) ]
        account_name = csvfile.readline().strip().strip(";")
        kontonr = account_name.split("Nr.")[1].strip() # get kontonummer
        if "Plus Konto online" in account_name:
            iban = assemble_iban("DE", "27020000", kontonr)
        else:
            iban = f"Unknown IBAN (Kontonr. {kontonr})"
        account_name = f"VW {account_name}" # -> VW Plus Konto online
        [ csvfile.readline() for _ in range(3) ]
        csvreader = csv.DictReader(csvfile, delimiter=";", quotechar="\"")
        rows = list(csvreader)

    fieldnames = [ "Auftragskonto", "Datum", "Verwendungszweck", "Betrag", "Waehrung" ] + csvreader.fieldnames

    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
        row["Auftragskonto"] = iban
        row["Datum"] = row["Buchungsdatum"]
        row["Verwendungszweck"] = row["Umsatzinformation"]
        row["Waehrung"] = "EUR"
        if len(row["Soll (EUR)"]) != 0:
            row["Betrag"] = - float(row["Soll (EUR)"].replace(",", "."))
        elif len(row["Haben (EUR)"].replace(",", ".")) != 0:
            row["Betrag"] = float(row["Haben (EUR)"].replace(",", "."))
        else:
            raise Exception("Unknown Betrag")

        writer.writerow(row)


def parse_n26(args):
    uuid = os.path.basename(args.input_csv).strip(".csv")
    kontonr = derive_account_number(uuid, "f5e510059cb5ff4268f5")
    iban = assemble_iban("DE", "10011001", kontonr)

    with open(args.input_csv, newline='') as csvfile:
        csvreader = csv.DictReader(csvfile, delimiter=",", quotechar="\"")
        rows = list(csvreader)

    fieldnames = [ "Auftragskonto" ] + csvreader.fieldnames

    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
        row["Auftragskonto"] = iban
        writer.writerow(row)


CRYPT_ITERATIONS = 5_000_000
CRYPT_HMAC = "sha256"
CRYPT_SALT = b"iban-acct-v1"

def _crypt_pad(uuid: str, n: int) -> bytes:
    return hashlib.pbkdf2_hmac(CRYPT_HMAC, uuid.encode(), CRYPT_SALT, CRYPT_ITERATIONS, n)

def _crypt_encrypt(uuid: str, account_number: str) -> str:
    acct = account_number.encode()
    return bytes(a ^ b for a, b in zip(acct, _crypt_pad(uuid, len(acct)))).hex()

def derive_account_number(uuid: str, blob_hex: str) -> str:
    """
    This function effectively decrypts the blob_hex with the uuid as a key,
    """
    raw = bytes.fromhex(blob_hex)
    ks  = hashlib.pbkdf2_hmac(CRYPT_HMAC, uuid.encode(), CRYPT_SALT, CRYPT_ITERATIONS, len(raw))
    return bytes(a ^ b for a, b in zip(raw, ks)).decode()

def iban_check_digits(country: str, blz: str, kontonr: str) -> str:
    """An iban looks like DEXX<"""
    """
    An iban looks like the folllowing. The bban is the iban without the first 4 characters.
    DE 11 11111111 1111111111
    │  │  │        └─ account number
    │  │  └────────── BLZ (bank code)
    │  └───────────── ISO 7064 mod-97 check digits
    └──────────────── country
    """
    rearranged = blz + kontonr + country + "00"
    n = int("".join(str(int(c, 36)) for c in rearranged))
    return f"{98 - n % 97:02d}"

def assemble_iban(country: str, blz: str, kontonr: str) -> str:
    return f"{country}{iban_check_digits(country, blz, kontonr)}{blz}{kontonr}"


def probe_parser(args):
    with open(args.input_csv, mode="r", encoding='utf-8-sig') as file:
        line = file.readline()
        if line.startswith("Kontoinhaber;"):
            return parse_vwbank
        if line.startswith('"Booking Date",'):
            return parse_n26
        else:
            raise Exception("Can't detect input format")

    raise Exception("Unreachable?")


def main():
    args = parse_args()

    parser = probe_parser(args)

    parser(args)



if __name__ == "__main__":
    main()
