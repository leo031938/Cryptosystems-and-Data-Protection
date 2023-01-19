###############################
#
# postdown.sh
#
###############################
#!/usr/bin/env bash
set -ex

# Traffic forwarding
iptables -D FORWARD -i Gateway1_wg0 -j ACCEPT
iptables -D FORWARD -o Gateway1_wg0 -j ACCEPT

# Nat
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
