job "showks" {
   datacenters = ["dc1"]
   group "showks-canvas" {
     count = 2
     network {
       mode ="bridge"
       port "http" {
         static = 9003
         to     = 8080
       }
     }

     service {
       name = "showks-canvas"
       port = "9003"
     }

     task "dashboard" {
       driver = "docker"
       config {
         image = "jacopen/showks-canvas:latest"
       }
     }
   }
 }

