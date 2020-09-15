# Adds a delay of 200ms to the egress scheduler

tc qdisc add dev eth0 root netem delay 200ms

# Delay of 100ms and random +-10ms uniform distribution

tc qdisc change dev eth0 root netem delay 100ms 10ms

# Delay of 100ms and random 10ms uniform variation with correlation value 25% 

tc qdisc change dev eth0 root netem delay 100ms 10ms 25%

# Delay of 100ms and random +-10ms normal distribution 

tc add dev eth0 root netem delay 100ms 20ms distribution normal

# Introduce a packet loss of 10%

tc qdisc add dev eth0 root netem loss 10%

# Corrupts 5% of the packets by introducing single bit error at a random offset in the packet

tc qdisc change dev eth0 root netem corrupt 5%

# Duplicates 1% of the sent packets

tc qdisc change dev eth0 root netem duplicate 1%

# Limit the egress bandwidth. Set the root queuing discipline of eth0 to tbf,
# with the output rate limited to 1 Mbps. Allows bursts of up to 32kbit to be
# sent at maximum rate. Packets accumulating a latency of over 400 ms due to
# the rate limitation are dropped.

tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms
