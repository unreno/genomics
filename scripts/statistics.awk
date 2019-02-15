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
#	printf("%s/%s/%s (%s)\n",min,sum/NR,max,sqrt((sumsq-sum^2/NR)/NR))
#	perhaps add a command line option to convert or not convert to integers
	printf("%s/%s/%s (%s)\n",int(min),int(sum/NR),int(max),sqrt((sumsq-sum^2/NR)/NR))
}
