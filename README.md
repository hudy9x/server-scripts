## Server scripts

### 1. Collect RAM usage

Use `./ram-usage.sh` to collect RAM stats every 5 seconds. This script send logs to [axiom.co](https://axiom.co) to visualize data. Run it as follow

```shell
$ wget https://raw.githubusercontent.com/hudy9x/server-scripts/main/ram-usage.sh 
$ vim ram-usage.sh 
$ chmod +x ram-usage.sh
$ nohup ./ram-usage.sh & > ram-usage-pid
```
