/*IMPORTING RAW DATA */
proc import datafile = "D:\Learners\project3\raw\lab_raw.csv"
	out = lab_raw
	dbms = csv replace;
	getnames = yes;
run;

/*CLEANING RAW DATA*/

/*PATIENT_ID*/
data id_clean;
	set lab_raw;
		cleaning_id = strip(upcase(patient_id));
		cleaning_id = compress(cleaning_id, ,'kad');

	if substr(cleaning_id,1,1) ne "P" then 
		cleaning_id = cats("P", put(input(cleaning_id, 8.),z3.));

	else do;
		number = input(substr(cleaning_id,2),8.);
		cleaning_id = cats("P", put(number, z3.));
	end;
	drop number;
	
run;

proc print data = id_clean;
	var patient_id cleaning_id;
run;

/*VISIT_DATE*/

data dates_clean;
	set id_clean;
		dt_clean = input(strip(upcase(visit_date)), anydtdte10.);
	format dt_clean date9.;
run;

proc print data = dates_clean;
	var visit_date dt_clean;
run;

/*LBTEST*/

proc freq data = dates_clean noprint;
	tables lbtest / out=lbtest_freq;
run;

proc export data=lbtest_freq
    outfile="D:\Learners\project3\lbtest_freq.csv"
    dbms=csv replace;
run;

proc import datafile="D:\Learners\project3\lbtest_mapping.csv"
    out=labmap dbms=csv replace;
    getnames=yes;
run;

proc contents data=labmap; run;

proc sql;
    create table lbtest_mapped as
    select a.*,
           b.standardized_value as lbtest_clean
    from dates_clean as a
    left join labmap as b
    on upcase(strip(a.lbtest)) = upcase(strip(b.lbtest));
quit;

proc freq data =lbtest_mapped;
	tables lbtest*lbtest_clean / missing list;
run;

proc print data = lbtest_mapped;
run;

proc sort data=lbtest_mapped noduprecs;
	by cleaning_id dt_clean lbtest_clean;
run;

/*RESULT*/

data result_clean;
	set lbtest_mapped;
	LBORRES = result;
	LBSTRESN = result;
run;

proc print data = result_clean noobs;
run;

/*UNIT*/

data unit_cleaned;
    set result_clean;
	length LBSTRESU $10; 
    LBORRESU = strip(unit);

    select (upcase(LBORRESU));
        when ("G/DL")  LBSTRESU = "g/dL";
        when ("MG/DL") LBSTRESU = "mg/dL";
        when ("/UL")   LBSTRESU = "/uL";
        when ("U/L")   LBSTRESU = "U/L";
        otherwise      LBSTRESU = "UNK";
    end;
run;


proc print data = unit_cleaned;
var unit LBORRESU LBSTRESU;
run;

/*LOW/HIGH*/

data low_clean;
	set unit_cleaned;
		clean_low= input(low, ?? best32.);
run;

proc print data = low_clean;
	var clean_low high anrind;
run;

/*ANRIND*/

data anrind_clean;
	set low_clean;
		anr_clean = upcase(strip(anrind));
		if anr_clean in ("LOW") THEN anr_clean = "LOW";
		else if anr_clean in ("HIGH") THEN anr_clean = "HIGH";
		else if anr_clean in ("NORMAL") THEN anr_clean = "NORMAL";
		else  anr_clean = "UNK";
run;

proc print data = anrind_clean;
	var clean_low high anr_clean;
run;

/*RECALCULATE ANRIND*/

data anrind_check;
    set low_clean;

    length derived_anrind $8;

    if not missing(LBSTRESN) then do;
        if not missing(clean_low) and LBSTRESN < clean_low then derived_anrind = "LOW";
        else if not missing(high) and LBSTRESN > high then derived_anrind = "HIGH";
        else if not missing(clean_low) and not missing(high) then derived_anrind = "NORMAL";
        else derived_anrind = "UNK"; 
    end;
    else derived_anrind = "UNK"; 
run;

proc print data = anrind_check;

run;

proc compare base=anrind_clean compare=anrind_check;
    id cleaning_id ;
    var anr_clean;
    with derived_anrind;
run;

data lb_final;
	set anrind_check
	(keep = cleaning_id
		 dt_clean
		 lbtest_clean
		 LBORRES
		 LBSTRESN
		 LBORRESU
		 LBSTRESU
		 clean_low
		 high
		 derived_anrind
	rename = (cleaning_id    = USUBJID
			  dt_clean       = LBDTC
			  lbtest_clean   = LBTEST
			  clean_low      = LBSTNRLO
			  high           = LBSTNRHI
			  derived_anrind = LBSTNRIND));
RUN;

data labtest;
    retain USUBJID LBDTC LBTEST LBORRES LBSTRESN LBORRESU LBSTRESU LBSTNRLO LBSTNRHI LBSTNRIND;
    set lb_final(keep=USUBJID LBDTC LBTEST LBORRES LBSTRESN LBORRESU LBSTRESU LBSTNRLO LBSTNRHI LBSTNRIND);
run;

proc print data = labtest;
run;

/*LISTING*/

proc print data=labtest noobs;
    var USUBJID LBDTC LBTEST LBSTRESN LBSTNRLO LBSTNRHI LBSTNRIND;
    title "Listing of Laboratory Test Results";
run;

/*TABLE*/

proc freq data=labtest;
    tables LBTEST*LBSTNRIND / nocol norow nopercent;
    title "Summary Table of Laboratory Test Results by Test and Range Indicator";
run;

/*FIGURES*/

proc sgplot data=labtest;
    vbar LBTEST / group=LBSTNRIND groupdisplay=cluster;
    title "Distribution of Laboratory Results by Test";
run;
































































































