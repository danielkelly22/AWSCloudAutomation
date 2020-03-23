sandbox_vpc_details = {
  primary = {
    cidr_block        = "10.201.152.0/22"
    environment_affix = "sandbox"
    subnets = {
      amt-sandbox-web-subnet = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 2, 0) = 10.98.0.0/23
          newbits = 2
          netnum  = 0
        }
      }
      amt-sandbox-app-subnet = {
        availability_zone = "us-east-1b"
        cidr = { # cidrsubnet("10.98.0.0/21", 2, 1) = 10.98.2.0/23
          newbits = 2
          netnum  = 1
        }
      }
      amt-sandbox-data-subnet = {
        availability_zone = "us-east-1a"
        cidr = { # cidrsubnet("10.98.0.0/21", 3, 4) = 10.98.4.0/24
          newbits = 2
          netnum  = 2
        }
      }
      # amt-sandbox-eks-subnet = {
      #   availability_zone = "us-east-1b"
      #   cidr = { # cidrsubnet("10.98.0.0/21", 3, 5) = 10.98.5.0/24
      #     newbits = 2
      #     netnum  = 3
      #   }
      # }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-sandbox-web-subnet"
    ],
    public_subnets = []
    nat_subnets    = {}
  }
  dr = {}
}
