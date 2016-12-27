FROM ubuntu:16.04

MAINTAINER Mario Zieschang <mzieschang@unitedprint.com>

RUN    apt-get update && apt-get upgrade -y && apt-get install -y make curl g++ gcc build-essential \
    && curl -L https://cpanmin.us | perl - App::cpanminus \
    && cpanm \
        Net::LDAP \
        Carp \
        Pod::Usage \
        Getopt::Long \
        DDP \
        Term::ReadKey \
        Pod::Coverage::TrustPod \
        Pod::Usage \
        Test::CheckManifest \
        Test::Pod \
        Test::Pod::Coverage \
        Test::Requires \
        Test::Spelling \
        Test::Net::LDAP \
    && apt-get remove --purge -y curl \
    && apt-get autoremove -y && apt-get clean && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cpanm/* /usr/share/man/* /usr/local/share/man/*

WORKDIR /app