###############################
#
# postup.sh
#
###############################
#!/usr/bin/env bash
set -ex

# Traffic forwarding
iptables -A FORWARD -i Gateway1_wg0 -j ACCEPT
iptables -A FORWARD -o Gateway1_wg0 -j ACCEPT

# Nat
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
