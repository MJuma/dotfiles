#!/bin/sh
# Print "n (m)" for the Herdr tab bar. n is the number of Copilot CLI sessions
# on this Herdr server, running and parked. m is the number that are parked.
# When no session is parked, print only "n".
# Herdr runs this script on the machine that runs the server.
herdr=${HERDR_BIN_PATH:-$HOME/.local/bin/herdr}
"$herdr" agent list 2>/dev/null | python3 -c '
import json, sys
agents = json.load(sys.stdin)["result"]["agents"]
running = sum(a.get("agent") == "copilot" for a in agents)
parked = sum(a.get("agent") == "parked" for a in agents)
total = running + parked
print(f"{total} ({parked})" if parked else total)
' 2>/dev/null
