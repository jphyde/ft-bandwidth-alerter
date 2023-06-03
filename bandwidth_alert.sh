source .env

DAY=$(date +%d)
MON=$(date +%m)

DAYS01="31";DAYS02="28";DAYS03="31";DAYS04="30";DAYS05="31";DAYS06="30"
DAYS07="31";DAYS08="31";DAYS09="30";DAYS10="31";DAYS11="30";DAYS12="31"

MON_HIST="$(curl -s "http://$FT_IP/bwm-monthly.asp" --user "$FT_USER:$FT_PASS" | tr -d '\r' | tr '\n' ' '| grep -ioE 'monthly_history\s*=\s*\[\s*(\[.*\],)*\[(.*)\]\];')"
#echo $MON_HIST

MON_HIST_DATA=$(printf '%s\n' "$MON_HIST" | sed -n 's/monthly_history\s*=\s*\[\s*\(\[.*\],\)*\[\([a-z0-9,]*\)\].*/\2/p')
#echo $MON_HIST_DATA

####TODO: if MON_HIST_DATA is empty email an alert and exit

MON_DT=$(echo $MON_HIST_DATA | cut -f1 -d,)
MON_DL=$(echo $MON_HIST_DATA | cut -f2 -d,)
MON_UL=$(echo $MON_HIST_DATA | cut -f3 -d,)
#echo $MON_DT
#echo $MON_DL
#echo $MON_UL

KBGBFACTOR=1048576

CURDAY=$(date +%d)
TOTDAYS=$(eval echo \$DAYS${MON})

####TODO: if leap year feb, increment by 1

DAYRATIO=$(awk "BEGIN {print ($CURDAY-1)/$TOTDAYS}")
DAYPRCNT=$(awk "BEGIN {print $DAYRATIO*100}")
CURUSAGE=$(($MON_DL+$MON_UL))
MAXGB=1536
MAXUSAGE=$(($MAXGB*$KBGBFACTOR))
USERATIO=$(awk "BEGIN {print $CURUSAGE/$MAXUSAGE}")
USEPRCNT=$(awk "BEGIN {print $USERATIO*100}")

REMUSAGE=$(($MAXUSAGE-$CURUSAGE))
REMGB=$(awk "BEGIN {print $REMUSAGE/$KBGBFACTOR}")
CURGB=$(awk "BEGIN {print $CURUSAGE/$KBGBFACTOR}")

REMDAYS=$(($TOTDAYS-$CURDAY))

echo "Current day: $CURDAY"
echo "Days in month: $TOTDAYS"
#echo $DAYRATIO
echo "Percent days elapsed: $DAYPRCNT%"
#echo
#echo $CURUSAGE
#echo $MAXUSAGE
#echo $USERATIO
echo
#echo $CURGB
#echo $REMGB
#echo
echo "GB used: $CURGB GB"
echo "GB remaining: $REMGB GB"
echo "Percent data used: $USEPRCNT%"
#echo
#echo $REMDAYS
#echo
if ((awk "BEGIN {exit !($CURDAY > 1)}")) && ((awk "BEGIN {exit !($USERATIO > $DAYRATIO)}")); then
SUBJ="You are outpacing your monthly data allowance"
TEXT="You are outpacing your monthly data allowance.\
GB used: $CURGB GB, GB remaining: $REMGB GB"
HTML="<p style='font-size:1.17em'>You are outpacing your monthly data allowance</p>\
<p>Month elapsed: $DAYPRCNT%<br>\
Data used: $USEPRCNT%</p>\
<p>GB used: $CURGB GB<br>\
GB remaining: $REMGB GB</p>"
echo $SCRIPT_DIR
$SCRIPT_PATH/emailer.sh "$SUBJ" "$TEXT" "$HTML"
echo
else echo "end";
fi
