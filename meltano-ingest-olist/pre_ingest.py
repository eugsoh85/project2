# remove BOM from CSV file

import csv
import os

FILE = "raw/product_category_name_translation.csv"
TEMP = "raw/_cleaned_temp.csv"

def clean_bom_header():
    with open(FILE, "r", encoding="utf-8") as infile, open(TEMP, "w", encoding="utf-8", newline="") as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        header = next(reader)
        # Remove BOM and strip whitespace
        cleaned_header = [col.replace('\ufeff', '').strip() for col in header]

        print(f"[INFO] Original header: {header}")
        print(f"[INFO] Cleaned header:  {cleaned_header}")

        writer.writerow(cleaned_header)

        for row in reader:
            writer.writerow(row)

    os.replace(TEMP, FILE)
    print(f"[SUCCESS] BOM removed and header cleaned.")

if __name__ == "__main__":
    clean_bom_header()