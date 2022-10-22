# Optional: Create a stable version of connectors.sh
export STAGING_BUCKET=dataproc-staging-us-central1-712368347106-boh5iflc
export TODAY=`date "+%Y%m%d"`
gsutil cp gs://goog-dataproc-initialization-actions-us-central1/connectors/connectors.sh  gs://${STAGING_BUCKET}/connectors/connectors_${TODAY}.sh

# The last updated connector is as of 20220605
# Optional: Use Dataproc Personal Cluster Authentication in "properties", this must be applied during cluster creation
# Somehow can't get this to work to query data from BigQuery
export REGION=us-central1
export CLUSTER_NAME=cluster-3ef8
export EMAIL=darrell.wang@fifty-five.com
gcloud dataproc clusters create ${CLUSTER_NAME} \
    --project=adroit-hall-301111 \
    --region=${REGION} \
    --properties=dataproc:dataproc.personal-auth.user=${EMAIL} \
    --zone=us-central1-f \
    --master-machine-type=n1-standard-8 \
    --master-boot-disk-size=500 \
    --num-workers=2 \
    --worker-machine-type=n1-standard-32 \
    --worker-boot-disk-size=500 \
    --image-version=2.0-debian10 \
    --optional-components=JUPYTER,DOCKER \
    --enable-component-gateway \
    --initialization-actions=gs://${STAGING_BUCKET}/connectors/connectors_20220605.sh \
    --metadata=GCS_CONNECTOR_VERSION=2.2.2 \
    --metadata=bigquery-connector-version=1.2.0 \
    --metadata=spark-bigquery-connector-version=0.21.0 \
    --scopes=https://www.googleapis.com/auth/cloud-platform

# Enable personal auth session if necessary.
# Note: You still need to authenticate with Kerberos and submit Spark jobs
# See here https://cloud.google.com/dataproc/docs/concepts/iam/personal-auth#dataproc-jupyter-console
gcloud dataproc clusters enable-personal-auth-session --region=${REGION} ${CLUSTER_NAME}