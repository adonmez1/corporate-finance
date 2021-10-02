libname my 'your-directory'; run;

/*input gvkey-date level data containing daily returns from your directory*/
data temp;
	set my.temp;
run;

data temp;
	set temp;
	log_ret=log(daily_ret+1); /*generate log returns*/
run;

proc sort data=temp; by gvkey current_date; run;

/*below calculates the cumulative log return between two arbitrary dates (lag_date and current_date) for observations having dummy variable equal to 1*/
%let begdate=01jan1999;
%let enddate=14may2020;

data swing_1m (drop=_:);
  array ret_history {%sysevalf("&begdate"d):%sysevalf("&enddate"d)} _temporary_;
  call missing(of ret_history{*});

  do until (last.gvkey);
    set temp;
    by gvkey;
    if dummy^=0 then ret_history{current_date}=log_ret;
  end;

  do until(last.gvkey);
    set temp;
	by gvkey;
	cum_ret=.;
	if dummy=1 then do _d=lag_date to current_date;
	  cum_ret=sum(cum_ret,ret_history{_d});
	end;
    output;
  end;
run;

data swing_1m;
	set swing_1m(keep=gvkey current_date lag_date cum_ret dummy);
	if dummy=1;
	ret=exp(cum_ret)-1; /*convert log return back to normal return*/
run;