devops_dir=$(cd $(dirname $0)/..; pwd)
env_root="${devops_dir}/terraform/environments"
env_dir="${env_root}/${TF_ENV}"
var_file="${env_dir}/terraform.tfvars"
secret_var_file="${env_dir}/terraform-secret.tfvars"
state_file="${env_dir}/terraform.tfstate"

function tf_bucket_name {
  if [[ -z $cached_tf_bucket_name ]]; then

    cached_tf_bucket_name=$(sed -n -e '/variable "terraform_bucket_name"/,/}/ p' ${env_root}/variables.tf  | \
      sed -nE -e "s/[[:space:]]*default[[:space:]]*=[[:space:]]*\"(.*)\"/\1/p"
    )

    if [[ -z $cached_tf_bucket_name ]]; then
        echo "Failed to lookup terraform bucket name" 1>&2
        exit 1
    fi

  fi

  echo $cached_tf_bucket_name
}

function lookup_account {
  ar_env=$1

  account=$(sed -n -e '/variable "aws_accounts"/,/}/ p' ${env_root}/variables.tf  | \
    sed -nE -e "s/[[:space:]]*${ar_env}[[:space:]]*=[[:space:]]*\"(.*)\"/\1/p"
  )

  if [[ -z $account ]]; then
      echo "Failed to lookup account for ${ar_env}" 1>&2
      exit 1
  fi

  echo $account
}

function aws_assume_role {
  ar_env=$1
  ar_role=$2

  if [[ $ar_env == "ops" ]]; then
    echo "Do not need to assume_role for the ops environment" 1>&2
    return
  fi

  account=$(lookup_account $ar_env)

  role="arn:aws:iam::${account}:role/${ar_role}"
  aws_tmp=$(mktemp -t aws-XXXX.json)

  aws sts assume-role --role-arn ${role} --role-session-name terraform > ${aws_tmp}

  aws_key=$(cat ${aws_tmp} | jq -r ".Credentials.AccessKeyId")
  aws_secret=$(cat ${aws_tmp} | jq -r ".Credentials.SecretAccessKey")
  aws_session_token=$(cat ${aws_tmp} | jq -r ".Credentials.SessionToken")
  aws_session_expiration=$(cat ${aws_tmp} | jq -r ".Credentials.Expiration")
}


function discover_aws_credentials {

  aws_region=${AWS_DEFAULT_REGION:-$(aws configure get region)}
  aws_key=${AWS_ACCESS_KEY_ID:-$(aws configure get aws_access_key_id)}
  aws_secret=${AWS_SECRET_ACCESS_KEY:-$(aws configure get aws_secret_access_key)}

  if [[ -z $aws_region || -z $aws_key || -z $aws_secret ]]; then
    echo "Could not get AWS credentials" 1>&2
    echo "Run 'aws configure' or set AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY/AWS_DEFAULT_REGION" 1>&2
    exit 1
  fi

}

function aws_env {
  if [[ -n $aws_session_token ]]; then
    export AWS_SESSION_TOKEN="$aws_session_token"
  fi
  export AWS_ACCESS_KEY_ID="$aws_key"
  export AWS_SECRET_ACCESS_KEY="$aws_secret"
  export AWS_DEFAULT_REGION="$aws_region"
  export TF_VAR_aws_region="$aws_region"

}

function manage_secrets {
  direction=$1

  case $direction in
    save)
      aws s3 cp --sse AES256 $secret_var_file s3://$(tf_bucket_name)/$TF_ENV/$(basename $secret_var_file)
      mv -f $secret_var_file $secret_var_file.backup
      ;;
    fetch)
      aws s3 cp s3://$(tf_bucket_name)/$TF_ENV/$(basename $secret_var_file) $secret_var_file
      ;;
    display)
      aws s3 cp s3://$(tf_bucket_name)/$TF_ENV/$(basename $secret_var_file) -
      ;;
    *)
      echo "Invalid direction for manage_secrets: ${direction}" 1>&2
      exit 1
      ;;
  esac

}

function manage_state {
  direction=$1

  case $direction in
    save)
      aws s3 cp --sse AES256 $state_file s3://$(tf_bucket_name)/$TF_ENV/$(basename $state_file)
      mv -f $state_file $state_file.backup
      ;;
    fetch)
      aws s3 cp s3://$(tf_bucket_name)/$TF_ENV/$(basename $state_file) $state_file
      rm -rf $(dirname $state_file)/.terraform
      ;;
    *)
      echo "Invalid direction for manage_state: ${direction}" 1>&2
      exit 1
      ;;
  esac

}

function get_tf_var {
  var_name=$1

  result=$(sed -n "s/^$var_name = \"\(.*\)\"/\1/p" $var_file)
  if [[ -z "$result" ]]; then

    if [[ -f $secret_var_file ]]; then
      result=$(sed -n "s/^$var_name = \"\(.*\)\"/\1/p" $secret_var_file)
    else
      result=$(sed -n "s/^$var_name = \"\(.*\)\"/\1/p" <(manage_secrets display))
    fi

  fi

  echo $result
}

function ecs_deploy {

  ENV=$1
  APP=$2

  echo "Deploying $APP to $ENV" 1>&2

  PREFIX="acme-${ENV}-"
  CLUSTER="${PREFIX}main"
  SVC="${PREFIX}${APP}"
  TASK="${PREFIX}${APP}"
  REPOSITORY="${PREFIX}${APP}"
  REGISTRY_ID=$(aws ecr describe-repositories | jq -r .repositories[0].registryId)
  REGISTRY="${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com"
  IMAGE="${REGISTRY}/${REPOSITORY}"
  REV_DATE=$(date +%Y%m%d%H%M%S)
  TRAVIS_COMMIT=${TRAVIS_COMMIT:-$(git rev-parse HEAD)}
  REV="${REV_DATE}-${TRAVIS_COMMIT::7}"

  eval $(aws ecr get-login)
  docker build -t $IMAGE:${REV} .
  docker tag -f $IMAGE:${REV} $IMAGE:latest
  docker push $IMAGE:${REV}
  docker push $IMAGE:latest

  docker run --rm \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN \
    -e AWS_DEFAULT_REGION \
    silintl/ecs-deploy \
      -c ${CLUSTER} -n ${TASK} -i ${IMAGE}:${REV} || true

  # Get list of older images (tag has date prefix, so we sort and
  # output all but last 10 (latest tag sorts to the end)
  # Note that pushing also creates an image without a tag, which sort
  # to the front, so we delete all of those as well
  old_images=$(
    aws ecr list-images --repository-name "${REPOSITORY}" | \
      jq -r '.imageIds | sort_by(.imageTag) | map("imageDigest=" + .imageDigest)[0:-11] | join(" ")' \
  )

  if [[ -n $old_images ]]; then
    aws ecr batch-delete-image \
      --repository-name "${REPOSITORY}" \
      --image-ids $old_images
  fi

  echo "Deploy of $APP to $ENV complete, image: ${IMAGE}:${REV}" 1>&2
}
