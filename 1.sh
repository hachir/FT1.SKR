
failmessage() {
	echo -ne "\033[31m      XXXXXX   XXXXXX   XXXXXXX  XX\033[0m\n"
	echo -ne "\033[31m      XX      XX    XX    XX     XX\033[0m\n"
	echo -ne "\033[31m      XX      XX    XX    XX     XX\033[0m\n"
	echo -ne "\033[31m      XXXXXX  XXXXXXXX    XX     XX\033[0m\n"
	echo -ne "\033[31m      XX      XX    XX    XX     XX\033[0m\n"
	echo -ne "\033[31m      XX      XX    XX  XXXXXXX  XXXXXX\033[0m\n"
}

if [ -z "$1" ]||[ -z "$2" ];then
	echo "upload_sfc.sh [full path to extracted test folder] [PASS/FAIL]"
	exit 0
fi

if [ ! -d "$1" ];then
	echo "Test logs in $1 do not exist"
	exit 1
fi

if [ "$2" != "PASS" ]&&[ "$2" != "FAIL" ];then
	echo "upload_sfc.sh [full path to extracted test folder] [PASS/FAIL]"
	exit 1
fi

logpath=$1
result=$2

rsn=`echo $logpath|cut -d'.' -f2|cut -d'_' -f1`
echo $rsn $result

if [ "$result" = "PASS" ];then
	#check result for numofpass
	passlog=`cat $logpath/FOX.${rsn}_summary_test_results.txt|grep PASS|wc -l`
	if [ $passlog -ne $numofpass ];then
		failmessage
		echo "Wrong PASS number in log, current: $passlog, should be: $numofpass"
		exit 1
	else
		python /root/LOCAL/UUTS/AutoPass/AutoPassDFMS.py $rsn AWSL12 WAIT
		python /root/LOCAL/UUTS/AutoPass/AutoPassDFMS.py $rsn AWSL12 PASS
		cd /home/RLTProject/
		./get_all_logs.sh $rsn 
		exitcode=$?
		if [ $exitcode -eq 1 ];then
			failmessage
			exit 1
		elif [ $exitcode -eq 2 ];then
			echo
			echo "*****************************************************"
			echo "  Remove extra QSFP Fiber and Run Final Switch Test"
			echo "*****************************************************"
		fi
	fi
fi
