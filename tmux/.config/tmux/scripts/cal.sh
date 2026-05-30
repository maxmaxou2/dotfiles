#!/bin/bash
# Show today's calendar events in tmux status bar (catppuccin module).
# Requires: brew install ical-buddy

if ! command -v icalBuddy &>/dev/null; then
  exit 0
fi

icalBuddy -nc -n -npn -nn eventsToday 2>/dev/null | head -3 | sed 's/^/📅 /'
