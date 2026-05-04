variable "REGISTRY_USER" {
    default = "ghcr.io/mehariwamlake"
}

variable "PYTHON_VERSION" {
    default = "3.11.6"
}

variable "NODE_VERSION" {
    default = "18.18.2"
}

variable "FRAPPE_VERSION" {
    default = "version-16"
}

variable "ERPNEXT_VERSION" {
    default = "version-16"
}

variable "FRAPPE_REPO" {
    default = "https://github.com/frappe/frappe"
}

variable "ERPNEXT_REPO" {
    default = "https://github.com/frappe/erpnext"
}

variable "BENCH_REPO" {
    default = "https://github.com/frappe/bench"
}

variable "LATEST_BENCH_RELEASE" {
    default = "latest"
}

# -------------------------
# TAG FUNCTION
# -------------------------
function "tag" {
    params = [repo, version]
    result = [
        "${REGISTRY_USER}/${repo}:${version}",
        "${REGISTRY_USER}/${repo}:latest"
    ]
}

# -------------------------
# DEFAULT ARGS
# -------------------------
target "default-args" {
    args = {
        FRAPPE_PATH     = "${FRAPPE_REPO}"
        ERPNEXT_PATH    = "${ERPNEXT_REPO}"
        BENCH_REPO      = "${BENCH_REPO}"
        FRAPPE_BRANCH   = "${FRAPPE_VERSION}"
        ERPNEXT_BRANCH  = "${ERPNEXT_VERSION}"
        PYTHON_VERSION  = "${PYTHON_VERSION}"
        NODE_VERSION    = "${NODE_VERSION}"
    }
}

# -------------------------
# ERPNext IMAGE (includes your app via apps.json)
# -------------------------
target "erpnext" {
    inherits = ["default-args"]
    context = "."
    dockerfile = "images/production/Containerfile"
    target = "erpnext"

    secret = [
        "id=apps_json,src=apps.json"
    ]

    tags = [
        "${REGISTRY_USER}/techvision-mail:${ERPNEXT_VERSION}",
        "${REGISTRY_USER}/techvision-mail:latest"
    ]
}

# -------------------------
# BASE + BUILD (optional debugging)
# -------------------------
target "base" {
    inherits = ["default-args"]
    context = "."
    dockerfile = "images/production/Containerfile"
    target = "base"

    tags = tag("frappe-base", "${FRAPPE_VERSION}")
}

target "build" {
    inherits = ["default-args"]
    context = "."
    dockerfile = "images/production/Containerfile"
    target = "build"

    secret = [
        "id=apps_json,src=apps.json"
    ]

    tags = tag("frappe-build", "${FRAPPE_VERSION}")
}

# -------------------------
# GROUPS
# -------------------------
group "default" {
    targets = ["erpnext"]
}