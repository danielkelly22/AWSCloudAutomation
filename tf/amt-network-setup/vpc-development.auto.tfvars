dev_vpc_details = {
  dr = {
    cidr_block        = "10.200.16.0/20"
    environment_affix = "dr-prod"
    subnets = {
      amt-dr-dev-web-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 0) = 10.200.16.0/23
          newbits = 3
          netnum  = 0
        }
      }
      amt-dr-dev-app-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 1) = 10.200.18.0/23
          newbits = 3
          netnum  = 1
        }
      }
      amt-dr-dev-data-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 2) = 10.200.20.0/23
          newbits = 3
          netnum  = 2
        }
      }
      amt-dr-dev-omnius-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 4, 6) = 10.200.22.0/24
          newbits = 4
          netnum  = 6
        }
      }
      amt-dr-dev-omnius-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 4, 7) = 10.200.23.0/24
          newbits = 4
          netnum  = 7
        }
      }
      amt-dr-dev-web-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 4) = 10.200.24.0/23
          newbits = 3
          netnum  = 4
        }
      }
      amt-dr-dev-app-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 5) = 10.200.26.0/23
          newbits = 3
          netnum  = 5
        }
      }
      amt-dr-dev-data-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 6) = 10.200.28.0/23
          newbits = 3
          netnum  = 6
        }
      }
    }
    subnet_shares = {
      omnius = {
        target_name               = "omnius_dev"
        allow_external_principals = false
        principal                 = "421354678477"
        subnets = {
          amt-dr-dev-omnius-subnet-a = {
            description = "Subnet zone A for the omni:us development environment"
          }
          amt-dr-dev-omnius-subnet-b = {
            description = "Subnet zone B for the omni:us development environment"
          }
        }
      }
    }
    transited_subnets = [
      "amt-dr-dev-app-subnet-a",
      "amt-dr-dev-app-subnet-b"
    ],
    internet_connected_subnets = {}
  }
}
