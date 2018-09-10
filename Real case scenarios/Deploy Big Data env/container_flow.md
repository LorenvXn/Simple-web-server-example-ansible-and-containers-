
Possible deployment flow (in order, for one container): <br>
(magic networking to happen if multiple containers)


```
                                     
                                        +-------------------------------+
                                        |choose service to be installed |
                                        +-------------------------------+
                                                    |
                                                    |
                                                    | 
                                                    |    
                                        +-------------------------+
                                        |  deploy container       |
                                        +-------------------------+
                                                    |   
                                                    | 
                                                    |    
                                                    |
                                        +-------------------------+
                                        |       start container   |
                                        +-------------------------+
                                                    |
                                                    |
                                                    |
                                        +------------------------------------+
                                        | attach storage to                  |                 
                                        |  running container... or not       |
                                        +------------------------------------+
                                                   |
                                                   |
                                                   |
                                        +-----------------------------+
                                        | container ready to be used  |
                                        +-----------------------------+
                                                   |
                                                   | 
                                                   |
                                        +------------------------------+
                                        | ability to delete container  |
                                        +------------------------------+
                                        
                                    
