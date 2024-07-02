#!/bin/bash

# Install OCI runtime
yum install -y containerd
systemctl daemon-reload
systemctl start containerd
cd /usr/local/
wget https://github.com/containerd/nerdctl/releases/download/v0.14.0/nerdctl-full-0.14.0-linux-amd64.tar.gz
tar -xvf nerdctl-full-0.14.0-linux-amd64.tar.gz
rm -f nerdctl-full-0.14.0-linux-amd64.tar.gz

# Mount floating DB volume
while aws ec2 describe-volumes --volume-ids ${disk_id} --region ${region} | grep AttachTime ; do
  aws ec2 detach-volume \
    --volume-id ${disk_id} \
    --force \
    --region ${region}
  echo "detaching volume from previous instance..."
  sleep 5
done
while ! aws ec2 describe-volumes --volume-ids ${disk_id} --region ${region} | grep AttachTime ; do
  aws ec2 attach-volume \
    --volume-id ${disk_id} \
    --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) \
    --region ${region} \
    --device /dev/sdf
  echo "attaching volume to current instance..."
  sleep 5
done

# Init volume folders
mkfs -t xfs /dev/xvdf || true
mkdir -p /data
mount /dev/xvdf /data
cd /data
mkdir -p ./Logs ./db
chmod -R 0777 /data

# Start OCI workflows
nerdctl run --restart=always -d --name=alphaserver -p 0.0.0.0:80:80 -p 0.0.0.0:15152:15152 -v $(pwd)/Logs:/app/Logs -v $(pwd)/db:/app/db ${payload_image}
sleep 60
nerdctl run --restart=always -d --name=sqlweb -p 0.0.0.0:8112:8080 -v $(pwd)/db:/data -e SQLITE_DATABASE=exteel.db ${db_image}
nerdctl ps -a