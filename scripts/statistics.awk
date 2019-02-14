BEGIN{
	max=-9999999;
	min=9999999;
}
{
	v=$1+0.0
	if(v>max){max=v};
	if(v<min){min=v};
	sum+=v;
	sumsq+=(v)^2
}
END{
	printf("%s/%s/%s (%s)\n",min,sum/NR,max,sqrt((sumsq-sum^2/NR)/NR))
}
