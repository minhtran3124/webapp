export WEBAPP_HOME="$PROJ_HOME/webapp"
export WEBAPP_SERVICE_NAME="${ENVIRONMENT}-webapp"


function webapp-service-build() {
    _util_print_information "Webapp: build"
}


function webapp-service-clean() {
    _util_print_information "Webapp: clean"
}


function webapp-service-deploy() {
    local deploy_file="${ENVIRONMENT}.yaml"

    _util_dir_push $WEBAPP_HOME

    _util_print_information "Webapp: deploy"

    gcloud app deploy $deploy_file --bucket $WEBAPP_BUCKET -q

    _util_dir_pop
}


function webapp-service-delete() {
    _util_print_information "Webapp: delete"

    gcloud app service delete $WEBAPP_SERVICE_NAME
}


function webapp-service-split-traffic() {
    local version1=$1
    local version1_weight=$2
    local version2=$1
    local version2_weight=$2

    _util_print_information "Webapp: split traffic"

    gcloud app services set-traffic $WEBAPP_SERVICE_NAME --splits $version1=$version1_weight,$version2=$version2_weight
}


function webapp-service-migrate-traffic() {
    local service_name=$1
    local version=$2

    _util_print_information "Webapp: migrate traffic"

    gcloud app services set-traffic $service_name --splits $version=1 -q
}


function webapp-service-browse() {
    _util_print_information "Webapp: browse"

    gcloud app browse -s $WEBAPP_SERVICE_NAME
}


function webapp-service-stream-logs() {
    _util_print_information "Webapp: stream logs"

    gcloud app logs tail -s $WEBAPP_SERVICE_NAME
}


function webapp-service-versions-list() {
    _util_print_information "Webapp: versions list"

    gcloud app versions list --service $WEBAPP_SERVICE_NAME
}


function webapp-service-migrate-traffic-version() {
    versions_arr=()

    for version in $(gcloud app versions list --service $WEBAPP_SERVICE_NAME --format="value(id)"); do
        versions_arr+=("${version}")
    done

    versions_arr+=("exit")

    _util_print_information "Webapp: migrate traffic"

    PS3="Please enter your version want to migrate traffic: "

    select verion in "${versions_arr[@]}"; do
        case $verion in
            exit)
                echo "Exiting"
                break
                ;;
            *)
                _util_print_information "Webapp: migrate traffic version $version"
                webapp-service-migrate-traffic $WEBAPP_SERVICE_NAME $version
                break
                ;;
        esac
    done
}
