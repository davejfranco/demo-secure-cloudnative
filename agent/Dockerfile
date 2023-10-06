FROM busybox

#Log Directory
RUN mkdir -p /var/log/agent 

#COPY Agent
COPY smith.sh /opt/smith.sh
RUN chmod +x /opt/smith.sh
#RUN Agent
#ENTRYPOINT ["/usr/local/bin/smith.sh"]
