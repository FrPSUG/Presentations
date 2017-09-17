@{
    AllNodes = 
    @(
        @{ 
            NodeName="*"  
            TemplateVHDX="m:\template\win2016.vhdx"                                         
        },
        @{ 
            NodeName="lab-xxxxx"                                   
            Role="HyperV"
            path="m:\vm\" 
            VMs=@(
            @{ 
                VMName="vm1"                                     
                VMMemory=2GB
                VMCpu=2        
                generation=2
                switchname= "fabric"
                path="vm1"
                        VHDs =@{
                            Name="web.vhdx"
                            Size=20GB
                            BlockSizeBytes=1MB
                            },    
                            @{
                            Name="log.vhdx"
                            Size=20GB
                            BlockSizeBytes=1MB
                            }            
              },
              @{    
                VMName="vm2"                                                                          
                VMMemory=1GB
                VMCpu=1        
                generation=2
                switchname= "fabric"
                path="vm2"
                        VHDs =@{
                            Name="web.vhdx"
                            Size=10GB
                            BlockSizeBytes=1MB
                            }            

              }
            )
        }
    )
}