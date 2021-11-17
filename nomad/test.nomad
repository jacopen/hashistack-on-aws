job "testapp" {
   datacenters = ["dc1"]
   group "api" {
     count = 2
     network {
       mode = "bridge"
     }

     service {
       name = "test-api"
       port = "9001"
     }

     task "web" {
       driver = "docker"
       config {
         image = "hashicorpnomad/counter-api:v1"
       }
     }
   }

   group "dashboard" {
     count = 2
     network {
       mode ="bridge"
       port "http" {
         static = 9002
         to     = 9002
       }
     }

     service {
       name = "test-dashboard"
       port = "9002"
     }

     task "dashboard" {
       driver = "docker"
       env {
         COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_count_api}"
       }
       config {
         image = "hashicorpnomad/counter-dashboard:v1"
       }
     }
   }
 }

