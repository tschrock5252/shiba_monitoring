# shiba_monitoring

## Purpose
This repository was created so I could monitor SHIB in my environment with a VM and get email alerts when it started to become more profitable.

While you can technically do this with apps and alerts on your phone, the apps get overloaded from time to time and I've also found they have some interesting ways of manipulating the price. 

The data crypto.com shows seems accurate, but I think they play with their prices using their javascript and other tools to manipulate the market a bit.

I wanted that fluctuation taken out of the equation with my purchasing decision(s). 

## Architecture Diagram(s)
![alt text](https://github.com/tschrock5252/shiba_monitoring/blob/master/shib_monitoring.png?raw=true)

## Requirement(s)

### Infrastructure
You will have to dedicate a VM or some form of infrastructure to this. I am sure you can get it to work in a container as well, but I have not tested that out yet.

I am running this at present on an Ubuntu 20.04.3 VM and am having no issues with the configuration. YMMV on other operating systems.

### Cron Daemon
You will need to configure a cron job to execute the [check_shiba_price.sh](https://github.com/tschrock5252/shiba_monitoring/blob/master/scripts/crypto/shiba/check_shiba_price.sh) script on a consistent basis.

I am running this every minute right now to pull data at a very steady basis.

An example cron is set up in this repository for you to view at the following location: [./shiba_monitoring/example.cron](https://github.com/tschrock5252/shiba_monitoring/blob/master/example.cron)

### Script(s)
This project's heart is currently built into a script that lives within the repository at [./shiba_monitoring/scripts/crypto/shiba/check_shiba_price.sh](https://github.com/tschrock5252/shiba_monitoring/blob/master/scripts/crypto/shiba/check_shiba_price.sh)

You will need to set this up in order for this project to be a success. The script will create the required directories for everything to run successfully.

#### Configurable Variables
The script has a large number of variables that you can configure and change if you want to.

I try to use variables heavily in all shell scripts I write. It makes configuration much easier for folks later.

To make this functional you at least have to change one that is in the script: **EMAIL_TO**

This variable configures where your alerts are going to be sent to when the price(s) of SHIB start to rise.

I also recommend you take a look at the following: 

```
SHIB_LOWER1=0.00008000;
SHIB_LOWER2=0.00010000;
SHIB_LOWER3=0.00100000;
SHIB_LOWER4=0.01000000;
```

These are the values to configure with regards to where you will start receiving alerts for this coin.

I only set the script up to monitor a total of four values via loop(s) at this time. More can be set up, but this is still a work in progress.

I will wait to see if I want something that alerts more.

### SSMTP
Your infrastructure needs to have SSMTP set up on it. This is a requirement for the [check_shiba_price.sh](https://github.com/tschrock5252/shiba_monitoring/blob/master/scripts/crypto/shiba/check_shiba_price.sh) script to work.

**Ubuntu Installation**:
```
# Install SSMTP
sudo apt install ssmtp
```
**RHEL/CentOS Install**:
```
# Remove postfix in case it is there
yum remove postfix

# Install SSMTP
yum install ssmtp --enablerepo=epel
```

You will also need to set up appropriate configuration for SSMTP.

**Ubuntu/RHEL/CentOS Location**: /etc/ssmtp/ssmtp.conf

An example of that is set up in this repository at the following location for you to reference: [./shiba_monitoring/etc/ssmtp/ssmtp.conf](https://github.com/tschrock5252/shiba_monitoring/blob/master/etc/ssmtp/ssmtp.conf)

#### SSMTP Configuration Notes

The email account that you are tying this to via config is not who you are _sending_ this to. 

The account you are tying this to via config is a relay account. The flow of data looks like this for mail.

**Local Server ---> GMail Relay Account ---> Target Email User Inbox**

It's important to keep this in mind in case mail relay starts failing.