# This is not part of the module as it is backend S3 bucket which I thought is best practise to create it 
# and persist it seperately

resource "aws_s3_bucket" "build-artifacts" {
    bucket = "devops-build-artifacts-eu-west-2"
    acl = "private"
}

resource "aws_s3_bucket_policy" "build-artifacts-policy" {
  bucket = aws_s3_bucket.build-artifacts.id
  policy = jsonencode({
    "Id": "AllowBucketAccess",
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DevopsUserAccess",
        "Action": [
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy",
          "s3:DeleteObject",
          "s3:DeleteObjectTagging",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
          "s3:GetBucketTagging",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging",
          "s3:ListBucket",
          "s3:PutBucketAcl",
          "s3:PutBucketPolicy",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Effect": "Allow",
        "Resource": [
            "${aws_s3_bucket.build-artifacts.arn}",
            "${aws_s3_bucket.build-artifacts.arn}/*"
        ],
        "Principal": {
          "AWS": [
            "arn:aws:iam::607160776561:user/devops"
          ]
        }
      }
    ]
  })
}
