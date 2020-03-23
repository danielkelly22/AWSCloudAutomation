shared_vpc_details = {
  primary = {
    cidr_block        = "10.98.0.0/21"
    environment_affix = "shared"
    subnets = {
      amt-shared-core-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 2, 0) = 10.98.0.0/23
          newbits = 2
          netnum  = 0
        }
      }
      amt-shared-core-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 2, 1) = 10.98.2.0/23
          newbits = 2
          netnum  = 1
        }
      }
      amt-shared-jump-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 4) = 10.98.4.0/24
          newbits = 3
          netnum  = 4
        }
      }
      amt-shared-jump-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 5) = 10.98.5.0/24
          newbits = 3
          netnum  = 5
        }
      }
      amt-shared-trainer-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 6) = 10.98.6.0/24
          newbits = 3
          netnum  = 6
        }
      }
      amt-shared-trainer-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 7) = 10.98.7.0/24
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
          amt-shared-trainer-subnet-a = {
            description = "Subnet zone A for the omni:us trainer environment"
          }
          amt-shared-trainer-subnet-b = {
            description = "Subnet zone B for the omni:us trainer environment"
          }
        }
      }
    }
    transited_subnets = [
      "amt-shared-core-subnet-a",
      "amt-shared-core-subnet-b"
    ],
    public_subnets = [
      "amt-shared-core-subnet-a",
      "amt-shared-core-subnet-b"
    ]
    nat_subnets = {}
  }
  dr = {
    cidr_block        = "10.98.128.0/21"
    environment_affix = "dr-shared"
    subnets = {
      amt-dr-shared-core-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 0) = 10.98.128.0/23
          newbits = 2
          netnum  = 0
        }
      }
      amt-dr-shared-core-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 1) = 10.98.130.0/23
          newbits = 2
          netnum  = 1
        }
      }
      amt-dr-shared-jump-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 4) = 10.98.132.0/24
          newbits = 3
          netnum  = 4
        }
      }
      amt-dr-shared-jump-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 5) = 10.98.133.0/24
          newbits = 3
          netnum  = 5
        }
      }
      amt-dr-shared-trainer-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 6) = 10.98.134.0/24
          newbits = 3
          netnum  = 6
        }
      }
      amt-dr-shared-trainer-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 7) = 10.98.135.0/24
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
      "amt-dr-shared-jump-subnet-a",
      "amt-dr-shared-jump-subnet-b"
    ],
    public_subnets = [
      "amt-dr-shared-core-subnet-a",
      "amt-dr-shared-core-subnet-b"
    ]
    nat_subnets = {}
  }
  sandbox = {
    cidr_block        = "10.201.144.0/22"
    environment_affix = "sandbox"
    subnets = {
      amt-sandbox-core-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 0) = 10.98.128.0/23
          newbits = 2
          netnum  = 0
        }
      }
      amt-sandbox-core-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 1) = 10.98.130.0/23
          newbits = 2
          netnum  = 1
        }
      }
      amt-sandbox-jump-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 4) = 10.98.132.0/24
          newbits = 3
          netnum  = 4
        }
      }
      amt-sandbox-jump-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 5) = 10.98.133.0/24
          newbits = 3
          netnum  = 5
        }
      }
      amt-sandbox-trainer-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 6) = 10.98.134.0/24
          newbits = 3
          netnum  = 6
        }
      }
      amt-sandbox-trainer-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 7) = 10.98.135.0/24
          newbits = 3
          netnum  = 7
        }
      }
    }
    subnet_shares = {
      # omnius = {
      #   target_name               = "omnius_nonprod"
      #   allow_external_principals = false
      #   principal                 = "421354678477"
      #   subnets = {
      #     amt-sandbox-trainer-subnet-a = {
      #       description = "Subnet zone A for the omni:us trainer environment"
      #     }
      #     amt-sandbox-trainer-subnet-b = {
      #       description = "Subnet zone B for the omni:us trainer environment"
      #     }
      #   }
      # }
    }
    transited_subnets = [
      "amt-sandbox-jump-subnet-a",
      "amt-sandbox-jump-subnet-b"
    ],
    public_subnets = [
      "amt-sandbox-core-subnet-a",
      "amt-sandbox-core-subnet-b"
    ]
    nat_subnets = {}
  }
}
