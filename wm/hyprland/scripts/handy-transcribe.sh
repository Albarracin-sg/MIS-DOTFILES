#!/bin/bash
# handy-transcribe.sh - Toggle handy recording + paste via wtype (Wayland)
# First press: start recording silently
# Second press: stop, transcribe, paste with wtype

STATE_FILE="/tmp/handy-recording.lock"

if [ -f "$STATE_FILE" ]; then
    # ── SECOND PRESS: Stop & paste ──
    rm -f "$STATE_FILE"

    # Stop recording via IPC to daemon
    # NOTA: corre en foreground para que espere a que termine la transcripción
    handy --start-hidden --toggle-transcription >/dev/null 2>&1

    # Paste the transcribed text from clipboard with wtype (Wayland-native)
    sleep 0.5
    wtype -M ctrl v -m ctrl
else
    # ── FIRST PRESS: Start recording ──
    touch "$STATE_FILE"
    handy --start-hidden --toggle-transcription >/dev/null 2>&1 &
    disown
fi
