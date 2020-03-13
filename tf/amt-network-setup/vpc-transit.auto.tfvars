transit_vpc_details = {
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
        cidr = { # cidrsubnet("10.200.8.0/21", 4, 1) = 10.200.9.0/24
          newbits = 3
          netnum  = 1
        }
      }
      amt-dr-transit-mgmt-subnet-a = {
        availability_zone = "us-east-2a"
        cidr = { # cidrsubnet("10.200.8.0/21", 6, 8) = 10.200.10.0/26
          newbits = 5
          netnum  = 8
        }
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-dr-transit-public-subnet-a"
    ],
    internet_connected_subnets = {
      amt-dr-transit-public-subnet-a  = "public"
      amt-dr-transit-private-subnet-a = "private"
      amt-dr-transit-mgmt-subnet-a    = "amt-dr-transit-private-subnet-a"
    }
  }
}
