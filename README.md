Basic config to distribute bandwidth equally among users. IP range is based on dhcp pool with a catch-all rule for static IPs set outside the pool. This is to keep the mangle and queue tree size manageable, but any range can be specified. Queue tree has a 2-tier structure to give clients that are browsing and/or light streaming(ie gaming, voip) higher priority. Also features "double qos" using pcq where not only is bandwidth distributed equally to all clients, but within each as well. So, if one client is downloading 2 heavy files, one of the files won't saturate all the bandwidth.  

The only downside of this config is that a client downloading hundreds of small streams(ie p2p) can saturate all of the bandwidth. Can be converted to 1-tier structure for 100% equal distribution by deleting the heavy tier in mangle and queue tree.

Script to populate mangle and queue is also included for easy modification. The script is only run once. To run it again, the mangle and queue rules it populates need to be deleted.
