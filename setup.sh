#!/bin/bash

execute() {
    # Disable ICMP broadcast echo activity
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1

    # Disable ICMP routing redirects
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.all.shared_media=1
    sysctl -w net.ipv4.conf.all.secure_redirects=1
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv6.conf.all.send_redirects=0

    # Enforce sanity checking, also called ingress filtering or egress filtering
    sysctl -w net.ipv4.conf.all.rp_filter=1

    # Log and drop "Martian" packets
    sysctl -w net.ipv4.conf.all.log_martians=1

    # Increase resiliance under heavy TCP load (which makes the system more resistant to SYN Flood attacks)
    sysctl -w net.ipv4.tcp_max_syn_backlog=1280
    sysctl -w net.ipv4.tcp_syncookies=1
    sysctl -w net.ipv4.tcp_fin_timeout=3
}

summary() {
    echo "This module will set system parameters which are known" 
    echo "known to harden the TCP stack against attack"
    echo "The following is a summary of the changes being made:"
    echo "   * Disable ICMP broadcast echo activity"
    echo "       * icmp_echo_ignore_broadcast=1"
    echo "   * Disable ICMP routing redirects"
    echo "       * accept_redirects=0"
    echo "       * shared_media=1"
    echo "       * secure_redirects=1"
    echo "       * accept_redirects=0"
    echo "       * send_redirects=0"
    echo "   * Enforce sanity checking"
    echo "       * rp_filter=1"
    echo "   * Log and drop Martian packets"
    echo "       * log_martians=1"
    echo "   * Increase resiliance under heavy TCP load (SYN flood attacks)"
    echo "       * tcp_max_syn_backlog=1200"
    echo "       * tcp_syncookies=1"
    echo "       * tcp_fin_timeout=3"
    echo ""
    printf "Continue with setting these parameters? (y/N): "
    read answer

    if [ "$answer" == "y" ] ; then
        execute
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
    summary
}

main
