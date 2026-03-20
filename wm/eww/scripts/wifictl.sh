MONITOR="${1:-0}"
ACTION="${2:-toggle}"

case "$ACTION" in
    "toggle")
        if [[ $("${eww_cmd}" get wifictlrev_${MONITOR}) == "true" ]]; then
            "${eww_cmd}" update wifictlrev_${MONITOR}=false
            "${eww_cmd}" close wifictl_${MONITOR}
        else
            "${eww_cmd}" update wifictlrev_${MONITOR}=true
            "${eww_cmd}" open wifictl_${MONITOR}
        fi
        ;;
    "open")
        "${eww_cmd}" update wifictlrev_${MONITOR}=true
        "${eww_cmd}" open wifictl_${MONITOR}
        ;;
    "close")
        "${eww_cmd}" update wifictlrev_${MONITOR}=false
        "${eww_cmd}" close wifictl_${MONITOR}
        ;;
esac
