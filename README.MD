# This is a working version of a test app which sits behind an ASG, fronted by an ALB
# State is stored locally for this demo

# To make it production ready
1.  Move ASG in private subnets.
2.  We can either use github actions which trigger the build like on dev when PR is raised and on production when PR is merged
3.  We can go for opensource solutions like jenkins, create jenkins pipelines for terraform plan and apply stages, ask user an input as yes or no for apply to have more control
4. Create a Cname record for the LB dns in the public hosted zone for the cint.com, it could be like app.cint.com. If the app is internal, we can probably create an r53 private hosted zone and create a cname record and app can use it.
5. Writing production ready code takes time, we should not hesitate to ask for reviews :) 
