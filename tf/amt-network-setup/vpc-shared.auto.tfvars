shared_vpc_details = {
  dr = {
    cidr_block        = "10.200.0.0/21"
    environment_affix = "dr-shared"
    subnets = {
      amt-dr-shared-core-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.0.0/21", 2, 0) = 10.200.0.0/23
          newbits = 3
          netnum  = 0
        }
      }
      amt-dr-shared-core-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.0.0/21", 3, 1) = 10.200.2.0/23
          newbits = 3
          netnum  = 1
        }
      }
      amt-dr-shared-jump-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.0.0/21", 3, 4) = 10.200.4.0/24
          newbits = 3
          netnum  = 4
        }
      }
      amt-dr-shared-jump-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.0.0/21", 4, 5) = 10.200.5.0/24
          newbits = 3
          netnum  = 5
        }
      }
      amt-dr-shared-trainer-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.0.0/21", 4, 6) = 10.200.6.0/24
          newbits = 3
          netnum  = 6
        }
      }
      amt-dr-shared-trainer-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.0.0/21", 4, 7) = 10.200.7.0/24
          newbits = 3
          netnum  = 7
        }
      }
    }
    subnet_shares = {
      omnius = {
        target_name               = "omnius_nonprod"
        allow_external_principals = false
        principal                 = "421354678477"
        subnets = {
          amt-dr-shared-trainer-subnet-a = {
            description = "Subnet zone A for the omni:us trainer environment"
          }
          amt-dr-shared-trainer-subnet-b = {
            description = "Subnet zone B for the omni:us trainer environment"
          }
        }
      }
    }
    transited_subnets = [
      "amt-dr-shared-core-subnet-a",
      "amt-dr-shared-core-subnet-b"
    ],
    internet_connected_subnets = {}
  }
}
