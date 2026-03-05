cat << EOF > /mnt/c/Users/lapin/.ssh/config.d/aws.conf
Host aws
    HostName ${hostname}
    User ${user}
    IdentityFile ${Identityfile}
EOF