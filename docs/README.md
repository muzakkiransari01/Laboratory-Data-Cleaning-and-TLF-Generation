# Clinical SAS Project 3 – Laboratory Data Cleaning and TLFs

This project focuses on cleaning and standardizing laboratory test data as per CDISC SDTM standards, and generating basic TLFs (Tables, Listings, and Figures).

   Steps Performed
1. Importing Raw Data – Read the raw lab dataset (`lab_raw.csv`).
2. Patient ID Cleaning – Standardized patient IDs (`USUBJID`).
3. Visit Date Conversion – Converted visit dates into standard SAS date format (`LBDTC`).
4. Lab Test Mapping – Standardized lab test names using a mapping file (`LBTEST`).
5. Lab Results – Derived original result (`LBORRES`) and numeric result (`LBSTRESN`).
6. Units Standardization – Standardized laboratory units (`LBORRESU`, `LBSTRESU`).
7. Reference Ranges – Cleaned low/high reference limits (`LBSTNRLO`, `LBSTNRHI`).
8. Range Indicator – Derived (`LBSTNRIND`: Low, Normal, High, Unknown).
9. Final Dataset – Created SDTM-style dataset `labtest`.
10. TLFs:
    - Listing of lab results.
    - Summary Table of lab tests by range indicator.
    - Figure** showing distribution by test and range indicator.


  Outputs
- Cleaned Dataset: `labtest`
- PDF Outputs (in /outputs):
- `TLF_listing.pdf`
- `TLF_summary_table.pdf`
- `TLF_figure.pdf`

---

  Notes
- Demonstrates data cleaning with `DATA` step, `PROC SQL`, and mapping tables.
- Validated derived variables (`LBSTNRIND`) using `PROC COMPARE`.
- Generated example TLFs for demonstration purposes.

👤 Author
Muzakkir Ansari
B.Sc. Statistics, 2024 | Mumbai, India
📧 muzakkiransari001@gmail.com


