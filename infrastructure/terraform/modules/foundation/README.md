# foundation

This terraform module contains resources required to get the EKS cluster up and running. The actual EKS cluster and nodegroups are included in the [eks module](../eks) in order to create a clean separation between the expensive stuff (EKS + Nodes) and the supportive resources such as IAM Roles and networking.
