This is a working version of a test app which sits behind an ASG, fronted by an ALB
State is stored locally

<!-- To make it production ready -->
# We can either use github actions which trigger the build like on dev when PR is raised and on production when PR is merged
# We can go for opensource solutions like jenkins, create jenkins pipelines for terraform plan and apply stages, ask user an input as yes or no for apply to have more control