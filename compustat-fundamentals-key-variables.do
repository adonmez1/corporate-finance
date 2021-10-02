clear
cd "your-directory"

use "compustat-fundamental-data.dta" /*Annual Compustat Fundamental Data*/

gen month=month(datadate)
gen f_year_end_y=year(datadate) 
gen year=f_year_end_y-1 if month<=5
replace year=f_year_end_y if month>5

drop f_year_end_y
rename year f_year_end_y

gen m=6
gen ym=ym(f_year_end_y,m)

sort gvkey f_year_end_y

replace che=ch+ivst if che==.

sort gvkey f_year_end_y
by gvkey: gen ROA = ib / at[_n-1] /*return on asset*/
by gvkey: gen cash = che / at /*cash*/

replace mkvalt=csho*prcc_f if mkvalt==. /*if mkvalt is missing, replace it by the value of common shares outstanding*/

sort gvkey f_year_end_y
by gvkey: gen bvps= pstkl
by gvkey: replace bvps= pstk if bvps==.
by gvkey: replace bvps= 0 if bvps==.
replace itcb=0 if itcb==.
by gvkey: gen be=seq+txdb+itcb-bvps
replace be=. if be<0
by gvkey: gen BM=be/mkvalt[_n-1] /*book-to-market ratio*/
by gvkey: gen BOOK=be

gen she=seq
replace she=ceq+pstk if she==.
replace she=at-lt-mib if she==.
gen lev=lt/she /*leverage ratio*/

gen year=fyear+1

keep gvkey csho fic sic mkvalt BM lev fyear prcc_f ROA cash

save "your-output-file.dta", replace
