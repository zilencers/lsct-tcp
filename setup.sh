#!/bin/bash

SYSCTL_CONF="/etc/sysctl.d/sysctl.conf"

file_exists() {
    if [ ! -f $SYSCTL_CONF ] ; then
        touch $SYSCTL_CONF
    fi
}

perf_tweaks() {
    echo "The following kernel parameters MAY help to increase network performance"
    printf "Continue (y/N): "
    read answer

    if [ "$answer" == "y" ] ; then
         echo ""
         echo "Increasing the size of the receiving queue"
	 echo "net.core.netdev_max_backlog = 16384" >> $SYSCTL_CONF

	 echo "Increasing performance for high speed large file transfer"
         echo "net.core.rmem_default = 1048576" >> $SYSCTL_CONF
         echo "net.core.rmem_max = 16777216" >> $SYSCTL_CONF
         echo "net.core.wmem_default = 1048576" >> $SYSCTL_CONF
         echo "net.core.wmem_max = 16777216" >> $SYSCTL_CONF
         echo "net.core.optmem_max = 65536" >> $SYSCTL_CONF
         echo "net.ipv4.tcp_rmem = 4096 1048576 2097152" >> $SYSCTL_CONF
         echo "net.ipv4.tcp_wmem = 4096 65536 16777216" >> $SYSCTL_CONF

	 echo "Increase the default UDP limits"
         echo "net.ipv4.udp_rmem_min = 8192" >> $SYSCTL_CONF
         echo "net.ipv4.udp_wmem_min = 8192" >> $SYSCTL_CONF

	 echo "Enable TCP Fast Open"
	 echo "net.ipv4.tcp_fastopen = 3" >> $SYSCTL_CONF

         echo "This setting kills persistent single connection performance"
	 echo "net.ipv4.tcp_slow_start_after_idle = 0" >> $SYSCTL_CONF

	 echo "Enable MTU probing, longer MTU is better for performace"
	 echo "net.ipv4.tcp_mtu_probing = 1" >> $SYSCTL_CONF
         echo ""
    fi

    sysctl -p $SYSCTL_CONF

    echo "Process Complete... "
    echo "Press any key to continue"
    read
}

sec_tweaks() {
    echo ""
    echo "Disabling ICMP broadcast echo activity"
    echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> $SYSCTL_CONF

    echo "Disabling ICMP routing redirects"
    echo "net.ipv4.conf.all.accept_redirects=0" >> $SYSCTL_CONF
    echo "net.ipv4.conf.default.accept_redirects=0" >> $SYSCTL_CONF
    echo "net.ipv4.conf.all.secure_redirects=0" >> $SYSCTL_CONF
    echo "net.ipv4.conf.all.send_redirects=0" >> $SYSCTL_CONF
    echo "net.ipv6.conf.all.accept_redirects=0" >> $SYSCTL_CONF
    echo "net.ipv6.conf.default.accept_redirects=0" >> $SYSCTL_CONF

    #  Indicates that the media is shared with different subnets
    echo "net.ipv4.conf.all.shared_media=1" >> $SYSCTL_CONF
    
    echo "Enforcing sanity checking, protect against IP spoofing"
    echo "net.ipv4.conf.default.rp_filter=1" >> $SYSCTL_CONF
    echo "net.ipv4.conf.all.rp_filter=1" >> $SYSCTL_CONF

    echo "Logging and dropping 'Martian' packets"
    echo "net.ipv4.conf.default.log_martians=1" >> $SYSCTL_CONF
    echo "net.ipv4.conf.all.log_martians=1" >> $SYSCTL_CONF

    echo "Increase resiliance under heavy TCP load (SYN Flood attacks)"
    echo "net.ipv4.tcp_max_syn_backlog=8192" >> $SYSCTL_CONF
    echo "net.ipv4.tcp_syncookies=1" >> $SYSCTL_CONF
    echo "net.ipv4.tcp_fin_timeout=6" >> $SYSCTL_CONF
    echo "net.ipv4.tcp_synack_retries=2" >> $SYSCTL_CONF

    echo "Increase max number of sockets in TIME_WAIT state, simple DOS protection"
    echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> $SYSCTL_CONF

    echo "Avoid running out of available network sockets, enabling tcp_reuse"
    echo "net.ipv4.tcp_tw_reuse = 1" >> $SYSCTL_CONF

    echo "Protect against tcp time-wait assassination hazards"
    echo "net.ipv4.tcp_rfc1337 = 1" >> $SYSCTL_CONF
    echo ""

    perf_tweaks
}

summary() {
    echo "This module will set kernel parameters which are known" 
    echo "to harden the TCP/IP stack against attack. Network performance"
    echo "improvements are also a part of the module. You will be given"
    echo "an option to install network tweaks as well"
    echo "The following is a summary of the changes being made:"
    echo "   * Disable ICMP broadcast echo activity"
    echo "   * Disable ICMP routing redirects"
    echo "   * Enforce sanity checking"
    echo "   * Log and drop Martian packets"
    echo "   * Increase resiliance under heavy TCP load (SYN flood attacks)" 
    echo "   * Protect against tcp time-wait assassination hazards" 
    echo "   * Avoid running out of available network sockets, enabling tcp_reuse" 
    echo "   * Increase max sockets in TIME_WAIT state, DOS protection" 
    echo ""
    printf "Continue with setting these parameters? (y/N): "
    read answer

    if [ "$answer" == "y" ] ; then
        sec_tweaks
    fi
}

title() {
    echo "------------------------------------------------------"
    echo "                  TCP Stack Hardening" 
    echo "------------------------------------------------------"
    echo ""
}

main() {
    title
    file_exists
    summary
}

main
