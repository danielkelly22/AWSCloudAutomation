uat_vpc_details = {
  primary = {
    cidr_block        = "10.98.32.0/20"
    environment_affix = "uat"
    extra_tags = {}
    subnets = {
      amt-uat-web-subnet-a = {
        availability_zone = "us-east-1a"
        # cidrsubnet(var.uat_vpc_details.primary.cidr_block, 3, 0)
        # 10.98.32.0/23
        cidr = {
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-uat-app-subnet-a = {
        availability_zone = "us-east-1a"

        # cidrsubnet(var.uat_vpc_details.primary.cidr_block, 3, 1)
        # 10.98.34.0/23
        cidr = {
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-uat-data-subnet-a = {
        availability_zone = "us-east-1a"

        # cidrsubnet(var.uat_vpc_details.primary.cidr_block, 3, 2)
        # 10.98.36.0/23
        cidr = {
          newbits = 3
          netnum  = 2
        }
        extra_tags = {}
      }
      amt-uat-web-subnet-b = {
        availability_zone = "us-east-1b"

        # cidrsubnet(var.uat_vpc_details.primary.cidr_block, 3, 4)
        # 10.98.40.0/23
        cidr = {
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-uat-app-subnet-b = {
        availability_zone = "us-east-1b"

        # cidrsubnet(var.uat_vpc_details.primary.cidr_block, 3, 5)
        # 10.98.42.0/23
        cidr = {
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-uat-data-subnet-b = {
        availability_zone = "us-east-1b"

        # cidrsubnet(var.uat_vpc_details.primary.cidr_block, 3, 6)
        # 10.98.44.0/23
        cidr = {
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-uat-app-subnet-a",
      "amt-uat-app-subnet-b"
    ],
    public_subnets = []
    nat_subnets    = {}
    isolated_subnets = []
  }
  dr = {
    cidr_block        = "10.98.160.0/20"
    environment_affix = "dr-uat"
    extra_tags = {}
    subnets = {
      amt-dr-uat-web-subnet-a = {
        availability_zone = "us-east-2a"

        # cidrsubnet(var.uat_vpc_details.dr.cidr_block, 3, 0)
        # 10.98.160.0/23
        cidr = {
          newbits = 3
          netnum  = 0
        }
        extra_tags = {}
      }
      amt-dr-uat-app-subnet-a = {
        availability_zone = "us-east-2a"

        # cidrsubnet(var.uat_vpc_details.dr.cidr_block, 3, 1)
        # 10.98.162.0/23
        cidr = {
          newbits = 3
          netnum  = 1
        }
        extra_tags = {}
      }
      amt-dr-uat-data-subnet-a = {
        availability_zone = "us-east-2a"

        # cidrsubnet(var.uat_vpc_details.dr.cidr_block, 3, 2)
        # 10.98.164.0/23
        cidr = {
          newbits = 3
          netnum  = 2
        }
        extra_tags = {}
      }
      amt-dr-uat-web-subnet-b = {
        availability_zone = "us-east-2b"

        # cidrsubnet(var.uat_vpc_details.dr.cidr_block, 3, 4)
        # 10.98.166.0/23
        cidr = {
          newbits = 3
          netnum  = 4
        }
        extra_tags = {}
      }
      amt-dr-uat-app-subnet-b = {
        availability_zone = "us-east-2b"

        # cidrsubnet(var.uat_vpc_details.dr.cidr_block, 3, 5)
        # 10.98.170.0/23
        cidr = {
          newbits = 3
          netnum  = 5
        }
        extra_tags = {}
      }
      amt-dr-uat-data-subnet-b = {
        availability_zone = "us-east-2b"

        # cidrsubnet(var.uat_vpc_details.dr.cidr_block, 3, 6)
        # 10.98.172.0/23
        cidr = {
          newbits = 3
          netnum  = 6
        }
        extra_tags = {}
      }
    }
    subnet_shares = {}
    transited_subnets = [
      "amt-dr-uat-app-subnet-a",
      "amt-dr-uat-app-subnet-b"
    ],
    public_subnets = []
    nat_subnets    = {}
    isolated_subnets = []
  }
}
