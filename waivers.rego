package fugue.regula.config

waivers[waiver] {
  waiver := {
      #Waiving the bucket logging rule for the logging bucket
    "rule_id": "FG_R00274",
    "resource_id": "module.s3.aws_s3_bucket.logbucket"
  }
}

rules[rule] {
  rule := {
    #Disabling this cross-region replication rule for budgetary purposes
    "rule_id": "FG_R00275",
    "status": "DISABLED"
  }
}