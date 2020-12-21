shared_vpc_details = {
  primary = {
    cidr_block        = "10.98.0.0/21"
    environment_affix = "shared"
    extra_tags = {}
    subnets = {
      amt-shared-core-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 2, 0) = 10.98.0.0/23
          newbits = 2
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-shared-core-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 2, 1) = 10.98.2.0/23
          newbits = 2
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-shared-jump-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 4) = 10.98.4.0/24
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-shared-jump-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 5) = 10.98.5.0/24
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-shared-trainer-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 6) = 10.98.6.0/24
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-shared-trainer-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 7) = 10.98.7.0/24
          newbits = 3
          netnum  = 7
        }
        extra_tags = {}
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
    isolated_subnets = []
  }
  dr = {
    cidr_block        = "10.98.128.0/21"
    environment_affix = "dr-shared"
    extra_tags = {}
    subnets = {
      amt-dr-shared-core-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 0) = 10.98.128.0/23
          newbits = 2
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-dr-shared-core-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 1) = 10.98.130.0/23
          newbits = 2
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-dr-shared-jump-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 4) = 10.98.132.0/24
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-dr-shared-jump-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 5) = 10.98.133.0/24
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-dr-shared-trainer-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 6) = 10.98.134.0/24
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-dr-shared-trainer-subnet-b = {
        availability_zone = "us-east-2b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 7) = 10.98.135.0/24
          newbits = 3
          netnum  = 7
        }
        extra_tags = {}
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
    isolated_subnets = []
  }
  cloudendure_replication = {
    cidr_block        = "10.98.64.0/23"
    environment_affix = "shared-cloudendure_replication"
    extra_tags = {
      cloudendure_environment = "shared-drtest"
      cloudendure_access_enabled = "true"
    }
    subnets = {
      amt-shared-cloudendure_replication-core-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.64.0/23", 1, 0) = 10.98.64.0/24
          newbits = 1
          netnum  = 0
        }
        extra_tags = {
          cloudendure_environment = "shared-drtest"
          cloudendure_access_enabled = "true"
        }
      }
      amt-shared-cloudendure_replication-core-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.64.0/23", 1, 1) = 10.98.65.0/24
          newbits = 1
          netnum  = 1
        }
        extra_tags = {
          cloudendure_environment = "shared-drtest"
          cloudendure_access_enabled = "true"
        }
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-shared-cloudendure_replication-core-subnet-a",
      "amt-shared-cloudendure_replication-core-subnet-b"
    ],
    public_subnets = [
      "amt-shared-cloudendure_replication-core-subnet-a",
      "amt-shared-cloudendure_replication-core-subnet-b"
    ]
    nat_subnets = {}
    isolated_subnets = []
  }
  drtest = {
    cidr_block        = "10.98.68.0/22"  # 10.98.68.0 - 10.98.71.255
    environment_affix = "shared-drtest"
    extra_tags = {
      cloudendure_environment = "shared-drtest"
      cloudendure_access_enabled = "true"
    }
    subnets = {
      amt-shared-drtest-jump-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.68.0/22", 3, 0) = 10.98.68.0 - 10.98.68.127
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-shared-drtest-jump-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.68.0/22", 3, 1) = 10.98.68.128 - 10.98.68.255
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-shared-drtest-isolated-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.68.0/22", 2, 1) = 10.98.69.0 - 10.98.69.255
          newbits = 2
          netnum  = 1
        }
        extra_tags = {
          cloudendure_environment = "shared-drtest"
          cloudendure_access_enabled = "true"
        }
      }
      amt-shared-drtest-isolated-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.68.0/22", 2, 1) = 10.98.70.0 - 10.98.70.255
          newbits = 2
          netnum  = 2
        }
        extra_tags = {
          cloudendure_environment = "shared-drtest"
          cloudendure_access_enabled = "true"
        }
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-shared-drtest-jump-subnet-a",
      "amt-shared-drtest-jump-subnet-b",
    ],
    public_subnets = []
    nat_subnets = {}
    isolated_subnets = [
      "amt-shared-drtest-isolated-subnet-a",
      "amt-shared-drtest-isolated-subnet-b"
    ]
  }
  sandbox = {
    cidr_block        = "10.201.144.0/22"
    environment_affix = "sandbox"
    extra_tags = {}
    subnets = {
      amt-sandbox-core-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 0) = 10.98.128.0/23
          newbits = 2
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-sandbox-core-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.128.0/21", 2, 1) = 10.98.130.0/23
          newbits = 2
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-sandbox-jump-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 4) = 10.98.132.0/24
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-sandbox-jump-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 5) = 10.98.133.0/24
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-sandbox-trainer-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 6) = 10.98.134.0/24
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
      amt-sandbox-trainer-subnet-b = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.128.0/21", 3, 7) = 10.98.135.0/24
          newbits = 3
          netnum  = 7
        }
        extra_tags = {}
      }
    }
    subnet_shares = { }
    transited_subnets = [
      "amt-sandbox-jump-subnet-a",
      "amt-sandbox-jump-subnet-b"
    ],
    public_subnets = [
      #   "amt-sandbox-core-subnet-a",
      #   "amt-sandbox-core-subnet-b"
    ]
    nat_subnets = {}
    isolated_subnets = []
  }
}
