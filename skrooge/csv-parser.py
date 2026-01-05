#!/usr/env/python3
import argparse
import csv
import sys

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
        [ csvfile.readline() for _ in range(6) ]
        csvreader = csv.DictReader(csvfile, delimiter=";", quotechar="\"")
        rows = list(csvreader)

    fieldnames = [ "Datum", "Verwendungszweck", "Betrag", "Waehrung" ] + csvreader.fieldnames

    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
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



def probe_parser(args):
    with open(args.input_csv, mode="r", encoding='utf-8-sig') as file:
        line = file.readline()
        if line.startswith("Kontoinhaber;"):
            return parse_vwbank
        else:
            raise Exception("Can't detect input format")

    raise Exception("Unreachable?")


def main():
    args = parse_args()

    parser = probe_parser(args)

    parser(args)



if __name__ == "__main__":
    main()
