* terraform
  * provision key pairs automatically?
  * provision certificates automatically (letsencrypt.org or aws certificate store)?
  * register env domain in upstream (production) route53 zone
  * [autoscale ecs cluster](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch_alarm_autoscaling.html) by setting up cloudwatch (autoscalegroup + launch_config already in place)
  * use Atlas (https://www.hashicorp.com/atlas.html)
  * Better [network layout](https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc#.bjocgtnev)?
* IAM
  * Grant VPN access based on IAM role
    * May need to use KMS to automatically add/store per-user passphrase
