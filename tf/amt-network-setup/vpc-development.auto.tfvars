dev_vpc_details = {
  primary = {
    cidr_block        = "10.98.16.0/20"
    environment_affix = "dev"
    extra_tags = {}
    subnets = {
      amt-dev-web-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.16.0/20", 3, 0) = 10.98.16.0/23
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-dev-app-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.16.0/20", 3, 1) = 10.98.18.0/23
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-dev-data-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.16.0/20", 3, 2) = 10.98.20.0/23
          newbits = 3
          netnum  = 2
        }
        extra_tags = {}
      }
      amt-dev-omnius-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.16.0/20", 4, 6) = 10.98.22.0/24
          newbits = 4
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-dev-omnius-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.16.0/20", 4, 7) = 10.98.23.0/24
          newbits = 4
          netnum  = 7
        }
        extra_tags = {}
      }
      amt-dev-web-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.16.0/20", 3, 4) = 10.98.24.0/23
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-dev-app-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.16.0/20", 3, 5) = 10.98.26.0/23
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-dev-data-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.16.0/20", 3, 6) = 10.98.28.0/23
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
    }
    amt-dev-omnius2-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.16.0/20", 4, 14) = 10.98.30.0/24
          newbits = 4
          netnum  = 14
        }
        extra_tags = {}
      }
      amt-dev-omnius2-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.16.0/20", 4, 15) = 10.98.31.0/24
          newbits = 4
          netnum  = 15
        }
        extra_tags = {}
      }
    subnet_shares = {
      omnius = {
        target_name               = "omnius_dev"
        allow_external_principals = false
        principal                 = "421354678477"
        subnets = {
          amt-dev-omnius-subnet-a = {
            description = "Subnet zone A for the omni:us development environment"
          }
          amt-dev-omnius-subnet-b = {
            description = "Subnet zone B for the omni:us development environment"
          }
          amt-dev-omnius2-subnet-a = {
            description = "Subnet zone A for the omni:us v2 development environment"
          }
          amt-dev-omnius2-subnet-b = {
            description = "Subnet zone B for the omni:us v2 development environment"
          }
        }
      }
    }
    transited_subnets = [
      "amt-dev-app-subnet-a",
      "amt-dev-app-subnet-b"
    ],
    public_subnets = []
    nat_subnets    = {}
    isolated_subnets = []
  }
  dr = {
    cidr_block        = "10.98.144.0/20"
    environment_affix = "dr-dev"
    extra_tags = {}
    subnets = {
      amt-dr-dev-web-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 0) = 10.200.16.0/23
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-dr-dev-app-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 1) = 10.200.18.0/23
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-dr-dev-data-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 2) = 10.200.20.0/23
          newbits = 3
          netnum  = 2
        }
        extra_tags = {}
      }
      amt-dr-dev-omnius-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.16.0/20", 4, 6) = 10.200.22.0/24
          newbits = 4
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-dr-dev-omnius-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 4, 7) = 10.200.23.0/24
          newbits = 4
          netnum  = 7
        }
        extra_tags = {}
      }
      amt-dr-dev-web-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 4) = 10.200.24.0/23
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-dr-dev-app-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 5) = 10.200.26.0/23
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-dr-dev-data-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.200.16.0/20", 3, 6) = 10.200.28.0/23
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
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
    public_subnets = []
    nat_subnets    = {}
    isolated_subnets = []
  }
}
