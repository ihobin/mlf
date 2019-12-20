#!/bin/sh

# print help
case $1 in
    -h|--help)
        echo -e "Multi Log files content Filter\nUsage: mlf.sh 'FILTER[|FILTER]' [FILE...]"
        exit 0
        ;;
esac

# init
TTY=$(tty)
NEWLINE=0
# filters
FILTERS=$1
FILTERS=${FILTERS// /__MLF_SPACE__}
FILTERS=${FILTERS//\\|/__MLF_VERTICAL__}
FILTERS=${FILTERS//|/ }
FILTERS=${FILTERS//__MLF_VERTICAL__/|}
# log files
shift 1
LOG_FILES=$@

# setting
REMOVALS="/home/hobin/bev/"
if [ "$LOG_FILES" == "" ]; then
    LOG_FILES="online/log/online_$(date +%Y%m%d).log zone/log/zone_$(date +%Y%m%d).log battlezone/log/zone_$(date +%Y%m%d).log"
fi

mlf_filter_impl()
{
    if [ "$FILTERS" == "" ]; then
        return 0
    fi
    for ftr in $FILTERS; do
        if [[ "$1" =~ "${ftr//__MLF_SPACE__/ }" ]]; then
            return 0
        fi
    done
    return 1
}

mlf_filter()
{
    content=$1
    for removal in $REMOVALS; do
       content=${content//$removal/}
    done
    if [ "$content" == "" ]; then
        return 0
    fi
    if [[ "$content" =~ "==> " ]] && [[ "$content" =~ " <==" ]]; then
        size=($(stty size -F $TTY))
        printf "\033[0;32;32m%-${size[1]}s\033[m\r" "$content"
        NEWLINE=1
    elif mlf_filter_impl "$content"; then
        if [ $NEWLINE -eq 1 ]; then
            NEWLINE=0
            printf "\n"
        fi
        printf "%s\n" "$content"
    fi
    return 0
}

tail -f $LOG_FILES|while read c; do mlf_filter "$c"; done
