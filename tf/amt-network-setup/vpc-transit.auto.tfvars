transit_vpc_details = {
  primary = {
    cidr_block        = "10.98.8.0/21"
    environment_affix = "transit"
    subnets = {
      amt-transit-public-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.8.0/21", 3, 0) = 10.98.8.0/24
          newbits = 3
          netnum  = 0
        }
      }
      amt-transit-private-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.8.0/21", 3, 1) = 10.98.9.0/24
          newbits = 3
          netnum  = 1
        }
      }
      amt-transit-mgmt-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.8.0/21", 5, 8) = 10.98.10.0/26
          newbits = 5
          netnum  = 8
        }
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
  }
  dr = {
    cidr_block        = "10.98.136.0/21"
    environment_affix = "dr-transit"
    subnets = {
      amt-dr-transit-public-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 0) = 10.98.136.0/24
          newbits = 3
          netnum  = 0
        }
      }
      amt-dr-transit-private-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 1) = 10.98.131.0/24
          newbits = 3
          netnum  = 1
        }
      }
      amt-dr-transit-mgmt-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.98.136.0/21", 5, 8) = 10.98.139.0/26
          newbits = 5
          netnum  = 8
        }
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
  }
  sandbox = {
    cidr_block        = "10.201.148.0/22"
    environment_affix = "sandbox"
    subnets = {
      amt-sandbox-transit-public-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 0) = 10.98.136.0/24
          newbits = 3
          netnum  = 0
        }
      }
      amt-sandbox-transit-private-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.136.0/21", 3, 1) = 10.98.131.0/24
          newbits = 3
          netnum  = 1
        }
      }
      amt-sandbox-transit-mgmt-subnet-a = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.136.0/21", 5, 8) = 10.98.139.0/26
          newbits = 5
          netnum  = 8
        }
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-sandbox-transit-private-subnet-a"
    ],
    public_subnets = ["amt-sandbox-transit-public-subnet-a"],
    nat_subnets = {
      amt-sandbox-transit-public-subnet-a  = "nat"
      amt-sandbox-transit-private-subnet-a = "amt-sandbox-transit-public-subnet-a"
      amt-sandbox-transit-mgmt-subnet-a    = "amt-sandbox-transit-public-subnet-a"
    }
  }
}
