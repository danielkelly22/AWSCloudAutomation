transit_vpc_details = {
  primary = {
    cidr_block        = "10.98.8.0/21"
    environment_affix = "transit"
    extra_tags = {}
    subnets = {
      amt-transit-public-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.8.0/21", 3, 0) = 10.98.8.0/24
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-transit-private-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.8.0/21", 3, 1) = 10.98.9.0/24
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-transit-mgmt-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.8.0/21", 5, 8) = 10.98.10.0/26
          newbits = 5
          netnum  = 8
        }
        extra_tags = {}
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-transit-private-subnet-a"
    ],
    public_subnets = ["amt-transit-public-subnet-a"],
    nat_subnets = {
      amt-transit-public-subnet-a  = "nat"
      amt-transit-private-subnet-a = "amt-transit-public-subnet-a"
      amt-transit-mgmt-subnet-a    = "amt-transit-public-subnet-a"
    }
    isolated_subnets = []
  }
  dr = {
    cidr_block        = "10.98.136.0/21"
    environment_affix = "dr-transit"
    extra_tags = {}
    subnets = {
      amt-dr-transit-public-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 0) = 10.98.136.0/24
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-dr-transit-private-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 1) = 10.98.131.0/24
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-dr-transit-mgmt-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.136.0/21", 5, 8) = 10.98.139.0/26
          newbits = 5
          netnum  = 8
        }
        extra_tags = {}
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-dr-transit-private-subnet-a"
    ],
    public_subnets = ["amt-dr-transit-public-subnet-a"],
    nat_subnets = {
      amt-dr-transit-public-subnet-a  = "nat"
      amt-dr-transit-private-subnet-a = "amt-dr-transit-public-subnet-a"
      amt-dr-transit-mgmt-subnet-a    = "amt-dr-transit-public-subnet-a"
    }
    isolated_subnets = []
  }
  sandbox = {
    cidr_block        = "10.201.148.0/22"
    environment_affix = "sandbox-local"
    extra_tags = {}
    subnets = {
      amt-sandbox-local-public-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 0) = 10.98.136.0/24
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-sandbox-local-private-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 1) = 10.98.131.0/24
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-sandbox-local-mgmt-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.136.0/21", 5, 8) = 10.98.139.0/26
          newbits = 5
          netnum  = 8
        }
        extra_tags = {}
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-sandbox-local-private-subnet-a"
    ],
    public_subnets = ["amt-sandbox-local-public-subnet-a"],
    nat_subnets = {
      amt-sandbox-local-public-subnet-a  = "nat"
      amt-sandbox-local-private-subnet-a = "amt-sandbox-local-public-subnet-a"
      amt-sandbox-local-mgmt-subnet-a    = "amt-sandbox-local-public-subnet-a"
    }
    isolated_subnets = []
  }
}
