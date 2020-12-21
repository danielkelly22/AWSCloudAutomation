prod_vpc_details = {
  primary = {
    cidr_block        = "10.98.48.0/20"
    environment_affix = "prod"
    extra_tags = {}
    subnets = {
      amt-prod-web-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.48.0/20", 3, 0) = 10.98.48.0/23
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-prod-app-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.48.0/20", 3, 1) = 10.98.50.0/23
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-prod-data-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.48.0/20", 3, 2) = 10.98.52.0/23
          newbits = 3
          netnum  = 2
        }
        extra_tags = {}
      }
      amt-prod-omnius-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.48.0/20", 4, 6) = 10.98.54.0/24
          newbits = 4
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-prod-omnius-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.48.0/20", 4, 7) = 10.98.55.0/24
          newbits = 4
          netnum  = 7
        }
        extra_tags = {}
      }
      amt-prod-web-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.48.0/20", 3, 4) = 10.98.56.0/23
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-prod-app-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.48.0/20", 3, 5) = 10.98.58.0/23
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-prod-data-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.48.0/20", 3, 6) = 10.98.60.0/23
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
    }
    subnet_shares = {
      omnius = {
        target_name               = "omnius_prod"
        allow_external_principals = false
        principal                 = "675938983696"
        subnets = {
          amt-prod-omnius-subnet-a = {
            description = "Subnet zone A for the omni:us application"
          }
          amt-prod-omnius-subnet-b = {
            description = "Subnet zone B for the omni:us application"
          }
        }
      }
    }
    transited_subnets = [
      "amt-prod-app-subnet-a",
      "amt-prod-app-subnet-b"
    ],
    public_subnets = []
    nat_subnets    = {}
    isolated_subnets = []
  }
  dr = {
    cidr_block        = "10.98.176.0/20"
    environment_affix = "dr-prod"
    extra_tags = {}
    subnets = {
      amt-dr-prod-web-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.176.0/20", 3, 0) = 10.98.176.0/23
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-dr-prod-app-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.176.0/20", 3, 1) = 10.98.50.0/23
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-dr-prod-data-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.176.0/20", 3, 2) = 10.98.52.0/23
          newbits = 3
          netnum  = 2
        }
        extra_tags = {}
      }
      amt-dr-prod-omnius-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.176.0/20", 4, 6) = 10.98.54.0/24
          newbits = 4
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-dr-prod-omnius-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.176.0/20", 4, 7) = 10.98.55.0/24
          newbits = 4
          netnum  = 7
        }
        extra_tags = {}
      }
      amt-dr-prod-web-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.176.0/20", 3, 4) = 10.98.56.0/23
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-dr-prod-app-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.176.0/20", 3, 5) = 10.98.58.0/23
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-dr-prod-data-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.176.0/20", 3, 6) = 10.98.60.0/23
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
    }
    subnet_shares = {
      omnius = {
        target_name               = "omnius_prod"
        allow_external_principals = false
        principal                 = "675938983696"
        subnets = {
          amt-dr-prod-omnius-subnet-a = {
            description = "Subnet zone A for the omni:us application"
          }
          amt-dr-prod-omnius-subnet-b = {
            description = "Subnet zone B for the omni:us application"
          }
        }
      }
    }
    transited_subnets = [
      "amt-dr-prod-app-subnet-a",
      "amt-dr-prod-app-subnet-b"
    ],
    public_subnets = []
    nat_subnets    = {}
    isolated_subnets = []
  }
}
