#!/bin/bash

if [[ $# == 1 ]]; then
    command=$1
    available_players=$(playerctl -l 2>/dev/null)

    if [[ $available_players == *"vlc"* ]]; then
        playerctl --player=vlc $command
    elif [[ $available_players == *"spotify"* ]]; then
        playerctl --player=spotify $command
    elif [[ -n $(xdotool search --name MusicBee 2>/dev/null) ]]; then
        musicbee_command=""
        case "$command" in
            "play-pause") musicbee_command="/PlayPause" ;;
            "stop") musicbee_command="/Stop" ;;
            "next") musicbee_command="/Next" ;;
            "previous") musicbee_command="/Previous" ;;
        esac
        env WINEPREFIX=~/.WineBee wine start /unix /media/Data/Programs/MusicBee/MusicBee.exe $musicbee_command
    elif [[ -n $available_players ]]; then
        playerctl $command
    fi
fi
