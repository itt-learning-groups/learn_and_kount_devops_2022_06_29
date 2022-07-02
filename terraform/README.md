For an example of IAM in terraform we'll create some roles and profiles and a base user that has limited permissions.

Our base user will only have permissions to list roles and to assume roles.

Next we'll create a couple of roles that the base user can assume.

The first an infra role that has s3 admin privileges and iam admin privileges. 

The second role is an admin role that can be assumed.

After the user and roles are created I have a couple small process to configure the base user profile with the created user credentials. Second an assume role process that the base user can use to assume a role and provision the default profile with the role temporary credentials.

Next we'll create a private s3 bucket 
