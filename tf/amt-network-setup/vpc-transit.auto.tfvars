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
      amt-transit-public-subnet-a  = "public"
      amt-transit-private-subnet-a = "private"
      amt-transit-mgmt-subnet-a    = "amt-transit-private-subnet-a"
    }
  }
  dr = {
    cidr_block        = "10.200.8.0/21"
    environment_affix = "dr-transit"
    subnets = {
      amt-dr-transit-public-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.8.0/21", 3, 0) = 10.200.8.0/24
          newbits = 3
          netnum  = 0
        }
      }
      amt-dr-transit-private-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.8.0/21", 3, 1) = 10.200.9.0/24
          newbits = 3
          netnum  = 1
        }
      }
      amt-dr-transit-mgmt-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.8.0/21", 5, 8) = 10.200.10.0/26
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
}
