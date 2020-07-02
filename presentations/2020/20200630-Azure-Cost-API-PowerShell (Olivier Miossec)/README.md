# Meetup FRPSUG 30/06/2020


Build the docker image 

```
docker build -t omcdemoaci-frpsug .
```

Tag the timage 
```
docker tag omcdemoaci-frpsug omcdockerreg01.azurecr.io/demoaci/omcdemoaci-frpsug:latest
```
Push the image 
```
docker push omcdockerreg01.azurecr.io/demoaci/omcdemoaci-frpsug:latest
```

Build the Container Instance 

```
az container create --resource-group <YourResourceGroup> --file aci.yml
```