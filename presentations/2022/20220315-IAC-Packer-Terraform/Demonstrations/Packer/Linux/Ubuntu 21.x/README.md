## Packer config to build Vsphere virtual machines templates from Ubuntu 20.04 live-server ISO file as a source.

I have used `iso_path` variable on ubuntu-21.xx.json. But Also I have added `iso_url` variable to variables.json. So If you dont have ready Ubuntu-21.xx live-server then you can basically change `iso_path` variable with `iso_url` in ubuntu-21.xx.json.

## Run packer build:

```bash
packer build -on-error=ask -var-file variables.json ubuntu-21.xx.json
```

## Change Password in user-data file

For the password you need to use **mkpasswd** with `sha-512` and **rounds=4096**

```bash
mkpasswd -m sha-512 --rounds=4096
password:
$6$rounds=4096$7CLeS7qFdnbW15jH$V.WnYZ1ekfHC5vyU0P2D3q5Ad8lW/ubeAiyilDMzxj6S2/qFZ6/KwOwEhxRqhD9kIrjsUW3w1Mdjnfok3/tiZ1
#here the result for the password P@ssw0rd!
```
Sio1234*