Basic config to distribute bandwidth equally among users. Queue tree has a 2-tier structure to give clients that are browsing and/or light streaming(ie gaming, voip) higher priority. Also features "double qos" where not only is bandwidth distributed equally to all clients, but within each as well. So, if one client is downloading 2 heavy files, one of the files won't saturate all the bandwidth.  

The only downside of this config is that a p2p client(hundreds of small streams) can saturate all of the bandwidth. Can be converted for 100% equal distribution by deleting the heavy tier in mangle and queue tree, however.

Script to populate mangle and queue is also included for easy modification. The script is only run once. To run it again, the mangle and queue rules it populates need to be deleted.
