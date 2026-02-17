MONITOR="${1:-0}"
ACTION="${2:-toggle}"

case "$ACTION" in
    "toggle")
        if [[ $(eww get wifictlrev_${MONITOR}) == "true" ]]; then
            eww update wifictlrev_${MONITOR}=false
            eww close wifictl_${MONITOR}
        else
            eww update wifictlrev_${MONITOR}=true
            eww open wifictl_${MONITOR}
        fi
        ;;
    "open")
        eww update wifictlrev_${MONITOR}=true
        eww open wifictl_${MONITOR}
        ;;
    "close")
        eww update wifictlrev_${MONITOR}=false
        eww close wifictl_${MONITOR}
        ;;
esac
