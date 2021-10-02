
signoff;
%let wrds = wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username='your_username' password='your_password';
libname my "your_wrds_directory"; run;
rsubmit;
%include '!SASROOT/wrdslib.sas';
libname my "your_wrds_directory"; run;

proc sql;
create table my.na_compustat as
select unique gvkey, iid, datadate, ajexdi, prccd, trfd, cshtrd,
tpci, curcdd, cshoc, adrrc, fic
from comp.secd /*comp.secd is the directory for compustat daily security data*/
where tpci in ('0','F')
order by gvkey, iid, datadate;
quit;

proc sort data=my.na_compustat;
by gvkey iid datadate;
run;

data my.na_compustat; set my.na_compustat;
by gvkey iid;
if first.iid then do;
mtrfd=trfd;
madrrc=adrrc;
end;
if trfd~=. then do;
mtrfd=trfd;
end;
retain mtrfd;
if adrrc~=. then do;
madrrc=adrrc;
end;
retain madrrc;
run;

*set missing values to 1;
data my.na_compustat; set my.na_compustat;
if madrrc=. then madrrc=1;
if mtrfd=. then mtrfd=1;
run;

proc sort data = my.na_compustat; by gvkey iid datadate; run;
data my.na_compustat; set my.na_compustat;
*forward fill the data;
trfd=mtrfd;
*set missing to 1;
if trfd=. then trfd=1;
if (cshtrd<=0 or cshtrd=.) then prccd=.; *set price to missing if no trading;
lgvkey=lag(gvkey);
liid=lag(iid);
ldatadate=lag(datadate);
lprccd=lag(prccd);
lajexdi=lag(ajexdi);
ltrfd=lag(trfd);
diff=intck('day',ldatadate,datadate);
mktcap = abs(cshoc*prccd);
lmktcap = lag(mktcap);
*likely to be ex-dividend return;
if gvkey=lgvkey and iid=liid and diff<5 then ret=(prccd/ajexdi*trfd)/(lprccd/lajexdi*ltrfd)-1;
*set missing return;
if ret<-0.9 then ret=.;
if ret>4 then ret=.;
lret=lag(ret);
if gvkey~=lgvkey or iid~=liid then lret=.;
run;

data my.na_compustat;
set my.na_compustat;
keep gvkey iid datadate ret mktcap lmktcap curcdd fic;
run;


proc sort data=my.na_compustat; by gvkey iid datadate mktcap; run;

/*drop multiple gvkey-iid-datadate occurences by keeping a gvkey-iid-date observation having the largest marketcap*/
data my.na_compustat;
	set my.na_compustat;
	by gvkey iid datadate;
	if last.datadate;
run;

proc expand data=my.na_compustat out=my.na_compustat method=none;
by gvkey iid;
id datadate;
convert ret = ret_1m / transformin=(+1) transformout=(REVERSE MOVPROD 22 -1 trimleft 11 REVERSE); /*1 month contains 22 trading days on average*/
convert ret = ret_3m / transformin=(+1) transformout=(REVERSE MOVPROD 66 -1 trimleft 33 REVERSE); /*3 months contains 66 trading days on average*/
convert ret = ret_6m / transformin=(+1) transformout=(REVERSE MOVPROD 126 -1 trimleft 63 REVERSE); /*6 months contains 126 trading days on average*/
convert ret = ret_12m / transformin=(+1) transformout=(REVERSE MOVPROD 252 -1 trimleft 126 REVERSE); /*12 months contains 252 trading days on average*/
quit;