BEGIN{
	FS=OFS="\t";
	max=-9999999;
	min=9999999;
}
{
	if(v>max){max=v};
	if(v<min){min=v};
	sum+=v;
	sumsq+=(v)^2
}
END{
	print(",%s/%s/%s (%s)",min,sum/NR,max,sqrt((sumsq-sum^2/NR)/NR))
}
